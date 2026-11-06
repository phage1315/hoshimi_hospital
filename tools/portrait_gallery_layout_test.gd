extends "res://tools/miyuki_lv3_retest.gd"
## Render every registered outfit/expression in the actual native detail pages.
## Deliberately isolated from player saves. Does not alter or export source artwork.
var output := ""
var compact_capture := false
var gui_only := false
var no_capture := false
var layout_observations: Array = []
func inspect_art(tag: String, expected_path: String, expected_size: Vector2, art_name: String = "CharacterPortrait") -> void:
	var art: TextureRect = app.page.get_node_or_null(art_name)
	expect(art != null, tag+" portrait exists")
	if art == null: return
	expect(art.texture != null, tag+" texture loads")
	if art.texture == null: return
	expect(art.size.is_equal_approx(expected_size),tag+" actual display size")
	expect(art.expand_mode == TextureRect.EXPAND_IGNORE_SIZE,tag+" ignores source minimum")
	expect(art.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED,tag+" keeps aspect")
	if not art.texture is AtlasTexture:
		expect(art.texture.resource_path == expected_path,tag+" expected asset")
	var texture_size: Vector2 = art.texture.get_size()
	var scale_factor: float = minf(art.size.x/texture_size.x,art.size.y/texture_size.y)
	var fitted := texture_size*scale_factor
	var rect := Rect2(art.position+(art.size-fitted)/2,fitted)
	expect(Rect2(0,145,1280,600).encloses(rect),tag+" artwork inside stage")
	for child in app.page.get_children():
		if child is Label and child.position.x == 65 and child.position.y >= 215:
			expect(child.position.x+child.size.x<=705.1,tag+" left text stays in column")
		if child is BaseButton and child.visible:
			expect(not rect.intersects(Rect2(child.position,child.size)),tag+" no button overlap "+str(child.name))
			expect(Rect2(0,0,1280,750).encloses(Rect2(child.position,child.size)),tag+" button inside canvas "+str(child.name))
	layout_observations.append({"variant":tag,"frame":[art.position.x,art.position.y,art.size.x,art.size.y],"source":[texture_size.x,texture_size.y]})
func screenshot(name: String) -> void:
	if no_capture: return
	await RenderingServer.frame_post_draw
	expect(root.get_texture().get_image().save_png(output+"/"+name+".png")==OK,"screenshot "+name)
func run() -> void:
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--out="): output=arg.trim_prefix("--out=")
		if arg=="--compact-capture": compact_capture=true
		if arg=="--gui-only": gui_only=true
		if arg=="--no-capture": no_capture=true
	assert(not output.is_empty())
	DirAccess.make_dir_recursive_absolute(output)
	native=DisplayServer.get_name()!="headless"
	expect(native,"native renderer")
	root.gui_embed_subwindows=true # Keep popup input in the native test viewport.
	app=load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path="/private/tmp/portrait_gallery_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	var counts := {"staff":0,"patients":0,"npc":0}
	var people := {}
	for locale in ([] if gui_only else ["zh_CN","en"]):
		expect(app.content.load_all(locale),"load "+locale)
		app.configure_game_content()
		app.game.reset()
		for collection in ["staff","patients"]:
			people[collection]=app.content.collections[collection].size()
			for person in app.content.collections[collection]:
				var seen_outfits := {}
				for key in person.visuals.portraits:
					var outfit: String=str(key).get_slice("/",0)
					var expression: String=str(key).get_slice("/",1)
					if collection=="staff": app.show_staff(person.id,"clinic",expression,outfit)
					else: app.show_patient(person.id,outfit,expression)
					await process_frame
					var tag: String=locale+"/"+person.id+"/"+str(key)
					inspect_art(tag,"res://"+str(person.visuals.portraits[key]),Vector2(470,500))
					if collection=="staff":
						var description: Label=app.page.get_node("StaffPersonality")
						var skills: Label=app.page.get_node("StaffSkills")
						expect(description.position.y+description.size.y<=skills.position.y,tag+" biography above skills")
						expect(skills.position.y+skills.size.y<=379,tag+" skills above relationship")
						var picker: OptionButton=app.page.get_node("StaffOutfitPicker")
						expect(str(picker.get_item_metadata(picker.selected))==outfit,tag+" outfit selection")
						var expressions: OptionButton=app.page.get_node("StaffExpressionPicker")
						expect(str(expressions.get_item_metadata(expressions.selected))==expression,tag+" expression selection")
					if not seen_outfits.has(outfit) and ((locale=="zh_CN" and not compact_capture) or seen_outfits.is_empty()):
						seen_outfits[outfit]=true
						await screenshot(locale+"_"+person.id+"_"+outfit)
					counts[collection]+=1
				print("CHECKED ",locale," ",person.id)
		var profile: Dictionary=JSON.parse_string(FileAccess.get_file_as_string("res://data/npcs/megumin/profile.json"))
		app.megumin_view.open_catalog(app)
		for key in profile.portraits:
			app.megumin_view.preview_art(str(key))
			await process_frame
			inspect_art(locale+"/npc_megumin/"+str(key),"res://"+str(profile.portraits[key]),Vector2(306.6667,460),"MeguminArtPreview")
			counts.npc+=1
		app.megumin_view.close_catalog()
	# Real GUI input smoke tests supplement the exhaustive render sweep.
	app.show_staff("doc_aoi","clinic","neutral","white_coat")
	await process_frame
	var outfit_picker: OptionButton=app.page.get_node("StaffOutfitPicker")
	var expected_outfit: String=str(outfit_picker.get_item_metadata(1))
	await click(outfit_picker)
	var outfit_popup: PopupMenu=outfit_picker.get_popup()
	await screenshot("gui_menu")
	expect(outfit_popup.visible,"GUI outfit popup opens")
	var popup_point := Vector2(outfit_popup.position)+Vector2(outfit_popup.size.x/2.0,outfit_popup.size.y*1.5/outfit_popup.item_count)
	var motion := InputEventMouseMotion.new();motion.position=popup_point;motion.global_position=popup_point;root.push_input(motion,true)
	for pressed in [true,false]:
		var event := InputEventMouseButton.new();event.button_index=MOUSE_BUTTON_LEFT;event.pressed=pressed
		event.position=popup_point;event.global_position=popup_point;root.push_input(event,true)
	await process_frame
	await process_frame
	var selected_picker: OptionButton=app.page.get_node("StaffOutfitPicker")
	expect(str(selected_picker.get_item_metadata(selected_picker.selected))==expected_outfit,"GUI outfit picker changes outfit")
	app.show_patient("patient_sora","ward","neutral")
	await process_frame
	await click(app.page.get_node("PatientExpression_smile"))
	expect(app.page.get_node("PatientExpression_smile").disabled,"GUI patient expression changes")
	await click(app.page.get_node("PatientOutfitLithotomy"))
	expect(app.page.get_node("CharacterPortrait").texture.resource_path.ends_with("/awake.png"),"GUI wrapped patient outfit button works")
	var report={"checks":checks,"failures":failures,"people":people,"variants_both_locales":counts,"layout_observations":layout_observations,"method":"native render sweep via actual detail-page functions; isolated memory; no player saves"}
	var f=FileAccess.open(output+"/result.json",FileAccess.WRITE)
	f.store_string(JSON.stringify(report,"  "));f.close()
	print("GALLERY LAYOUT: ",checks," checks; ",failures," failures; ",counts)
	quit(1 if failures else 0)

extends SceneTree
## Native-window or headless production-path QA. Fixtures exist in memory only.
const Registry = preload('res://godot/systems/free_h_registry.gd')
const Session = preload('res://godot/systems/h_profile_v1_session.gd')
var app
var checks := 0
var failures := 0
var captures: Array[String] = []
const OUT := 'res://docs/qa/serika_free_h/native'
const PIXELS := {'lips':Vector2(520,350),'cheeks':Vector2(435,290),'neck':Vector2(520,462),'breasts':Vector2(400,650),'nipples':Vector2(326,606),'navel':Vector2(511,970),'torso_other':Vector2(510,850),'genitals':Vector2(510,1320),'thighs':Vector2(250,1210)}
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred('run')
func capture(tag: String) -> void:
	if DisplayServer.get_name() == 'headless': return
	await process_frame
	await RenderingServer.frame_post_draw
	var path := OUT+'/'+tag+'.png'
	expect(root.get_texture().get_image().save_png(path) == OK, 'Save rendered evidence '+tag)
	captures.append(path)
func permanent() -> Dictionary:
	var result := {}
	for key in ['relationships','story_flags','surgery_xp','leadership_xp','archived_player_effects','special_event_completion_counts','special_event_completion_days']:
		var value: Variant = app.game.get(key)
		result[key] = value.duplicate(true) if value is Dictionary or value is Array else value
	return result
func portrait(expression: String) -> void:
	var node = app.page.get_node_or_null('HProfileExpression')
	expect(node != null and node.texture != null, 'Visible portrait '+expression)
	if node == null or node.texture == null: return
	expect(node.texture.resource_path == 'res://assets/h/doc_serika/portrait_'+expression+'.png', 'Correct expression texture '+expression)
	expect(node.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, 'Portrait aspect ratio '+expression)
func click_zone(action: String, zone: String) -> void:
	app._select_sayaka_h_action(action)
	var body = app.page.get_node('HProfileBodyMap')
	var event := InputEventMouseButton.new()
	event.pressed = true
	event.button_index = MOUSE_BUTTON_LEFT
	event.position = PIXELS[zone] / Vector2(1024,1536) * body.size
	body.gui_input.emit(event)
	expect(app.h_profile_test_last_result.get('zone') == zone and app.h_profile_test_last_result.get('accepted',false), 'Live input '+action+':'+zone)
func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	app = load('res://godot/scenes/main.tscn').instantiate()
	app.saves.path = '/private/tmp/hoshimi-serika-e2e-unused-%d.json' % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ['zh_CN','en']:
		app.game.reset()
		expect(app.content.load_all(locale), 'Load '+locale)
		app.configure_game_content()
		app.show_map(false)
		app.game.meet_staff('doc_serika')
		var relation: Dictionary = app.game.relation_for('doc_serika')
		relation.level = 4
		relation.route = 'romance'
		relation.unlocked_benefits = ['unlock_intimacy_events']
		expect(not app.game.free_h_unlocked('doc_serika'), 'Lv4 number and benefit alone do not bypass completed-event requirement')
		app.game.special_event_completion_counts['serika_lv4_stay'] = 1
		app.game.special_event_completion_days['serika_lv4_stay'] = 1
		app.game.advance_story_to_day(8,9*60)
		# Stable daily presence fact, so QA does not depend on the campaign's 70% draw.
		app.game.set_story_flag('serika_imaging_present:8')
		expect(app.game.free_h_unlocked('doc_serika'), 'Real completion fact enables route')
		var source_location := ''
		for location in app.content.collections.locations:
			if 'doc_serika' in app.game.staff_present_at(str(location.id)):
				source_location = str(location.id)
				break
		expect(not source_location.is_empty(), 'Locate actor through actual presence resolver')
		if source_location.is_empty(): quit(1); return
		var bundle := Registry.load_bundle('doc_serika',locale)
		expect(not bundle.has('error'), 'Complete production asset bundle '+locale)
		if bundle.has('error'): quit(1); return
		var before := permanent()
		app.show_staff('doc_serika',source_location)
		var booking = app.page.get_node_or_null('FreeHBooking')
		expect(booking != null, 'Normal staff menu invitation')
		if booking == null: quit(1); return
		booking.pressed.emit()
		expect(app.game.free_h_booking.get('actor_id') == 'doc_serika', 'Booking through menu')
		expect(app.page.get_node_or_null('FreeHLocationPicker') == null, 'Fixed home skips picker')
		await capture(locale+'_booking')
		app.show_map(false)
		expect(app.game.can_save_progress(), 'Hospital boundary permits save')
		app.game.advance_story_to_day(8,16*60)
		app.request_end_workday()
		await create_timer(1.1).timeout
		expect(app.h_profile_test_session != null and app.h_profile_run_kind == 'free', 'After-work departure launches production runner')
		if app.h_profile_test_session == null: quit(1); return
		expect(app.h_profile_test_session.actor_id == 'doc_serika' and app.h_profile_test_session.event_id.is_empty(), 'Own actor with repeatable context')
		expect(app.h_profile_test_entry_lines.size() == 1, 'One entry drawn from authored pool')
		expect(not app.game.can_save_progress(), 'No entry save')
		portrait('neutral')
		await capture(locale+'_entry')
		app._advance_sayaka_h_entry()
		portrait('neutral')
		await capture(locale+'_neutral')
		for wanted in ['annoyed','pleased','flustered','delighted']:
			var chosen: Array = []
			for action in Session.ACTIONS:
				for zone in Session.ZONES:
					var session = app.h_profile_test_session
					var tier: String = session.preference_for(action,zone)
					var reaction: Dictionary = session.reaction_for(action,zone,tier)
					if reaction.get('expression',Session.DEFAULT_EXPRESSION_BY_TIER[tier]) == wanted:
						chosen = [action,zone]
						break
				if not chosen.is_empty(): break
			expect(not chosen.is_empty(), 'Authored reaction exists for '+wanted)
			if chosen.is_empty(): continue
			click_zone(chosen[0],chosen[1])
			portrait(wanted)
			await capture(locale+'_'+wanted)
		for step in range(60):
			if app.h_profile_test_session.excitement >= 100: break
			click_zone('caress','cheeks')
		expect(app.h_profile_test_session.excitement == 100 and app.h_profile_test_max_prompt_visible, 'MAX reached through actual clicks')
		portrait('peak')
		await capture(locale+'_peak')
		expect(not app.game.can_save_progress(), 'No interaction save')
		var style := 'gentle' if locale == 'zh_CN' else 'intense'
		app.page.get_node('HProfileStyleGentle' if style == 'gentle' else 'HProfileStyleIntense').pressed.emit()
		for line in range(6):
			expect(app.page.get_node('HProfileSceneImage').texture.resource_path == 'res://assets/h/doc_serika/scene_cg.png', 'Own stage CG')
			expect(app.page.get_node('HProfileDialogueSpeaker').text == ('Serika Misono' if locale == 'en' else '御園芹香'), 'Correct speaker')
			expect(not app.game.can_save_progress(), 'No stage save')
			if line == 0: await capture(locale+'_stage')
			app.page.get_node('HProfileAdvance').pressed.emit()
		expect(app.h_profile_test_session.phase == 'h_finish_wait', 'Manual completion wait')
		app.page.get_node('HProfileFinish').pressed.emit()
		expect(app.h_profile_test_session.phase == 'h_finish_response', 'Completion response displayed')
		app.page.get_node('HProfileAdvance').pressed.emit()
		await create_timer(4.8).timeout
		expect(app.h_profile_test_session.phase == 'after_cg', 'Transition to authored aftercare')
		expect(app.page.get_node('HProfileSceneImage').texture.resource_path == 'res://assets/h/doc_serika/aftercare_cg.png', 'Own aftercare CG')
		expect(not app.game.can_save_progress(), 'No aftercare save')
		await capture(locale+'_aftercare')
		app._advance_sayaka_h_aftercare()
		expect(not app.game.active_free_h_departure.is_empty(), 'Continue before final text')
		app._advance_sayaka_h_aftercare()
		expect(app.h_profile_test_session == null and app.screen == 'day_transition', 'Complete returns to day transition')
		expect(app.game.free_h_booking.is_empty() and app.game.active_free_h_departure.is_empty(), 'Booking cleared only on completion')
		expect(app.game.day_number() == 9, 'Advance exactly one day')
		expect(permanent() == before, 'No permanent relationship rewards or milestone replay')
		expect(app.game.finish_free_h_departure().is_empty() and app.game.day_number() == 9, 'Duplicate completion harmless')
		app.continue_after_day_transition()
		expect(app.screen == 'map' and app.game.can_save_progress(), 'Return to safe hospital boundary')
		await capture(locale+'_return')
	expect(not FileAccess.file_exists(app.saves.path), 'No player or test save written')
	var report := {'checks':checks,'failures':failures,'display_server':DisplayServer.get_name(),'captures':captures,'player_saves_written':false,'locales':['zh_CN','en'],'styles':['gentle','intense'],'fixture':'in-memory completed Lv4 fact; natural Lv4 unlock chain not replayed'}
	var file := FileAccess.open(OUT+'/results.json',FileAccess.WRITE)
	file.store_string(JSON.stringify(report,'\t')+'\n')
	print('SERIKA E2E: ',checks,' checks; ',failures,' failures; display=',DisplayServer.get_name())
	quit(1 if failures else 0)

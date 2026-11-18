extends SceneTree
## Native windowed UI playthrough & preview screenshot capture for
## Miyama Kaori's Relationship Lv3 event: 《手术室之神》 (miyama_03_or_god V1.2).
## Exercises GUI input, verifies 1s CG delay reveal, seasonal casual & night street
## switching (Spring vs Autumn/Winter), and captures zh_CN + en 1280x800 previews.

const LV1_ID := "miyama_01_safety_pin"
const LV2_ID := "miyama_02_manga_artist_wrong_patient"
const EVENT_ID := "miyama_03_or_god"
const OUT_DIR := "docs/qa/kaori_lv3_v1_2_2026-11-13"

const ZH_CAPTURES := {
	"s02_020": "01_zh_day1_rooftop_coffee.png",
	"s03_006": "01b_zh_day2_nurses_station_hiroko.png",
	"s04_012": "01c_zh_director_office_asuka.png",
	"s05_014": "02_zh_or3_cap_asleep.png",
	"s05_017": "03_zh_or3_cap_embarrassed.png",
	"s06_012": "03b_zh_or3_asuka_exorcism_gag.png",
	"s07_013": "04a_zh_kasumi_or_cap_tense.png",
	"s07_014": "04_zh_cg_emergency_command.png",
	"s07_021": "04c_zh_kasumi_shocked_feverish.png",
	"s07_023": "04b_zh_kasumi_mask_drowsy.png",
	"s08_013": "05_zh_scrub_masked_choice1.png",
	"s09_006": "05b_zh_or2_gowning_moe_ange.png",
	"s09_017": "06_zh_cg_sterile_gown_rear.png",
	"s10c_002": "06b_zh_stage10c_calot_choice2.png",
	"s10e_018": "07_zh_stage10e_paracolic_pocket.png",
	"s11_012": "07b_zh_kasumi_ward_confused.png",
	"s11_030": "07c_zh_hallway_sample_size_three.png",
	"s12_016": "08_zh_spring_street_small_smile.png",
	"s12_043": "09_zh_station_farewell_small_smile.png",
}

var app
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func setup_lv3_ready(target_day: int) -> void:
	app.game.reset()
	var intro = app.game.start_character_event("intro_doc_rei")
	while intro != null and not intro.completed:
		app.game.choose_character_event(str(intro.current().choices[0].id))
	app.game.active_character_event_id = ""
	app.game.active_mode = "encounter"
	app.game.meet_staff("doc_asuka")
	app.game.add_familiarity("doc_rei", 10)
	app.game.advance_story_to_day(4, 540)
	app.game.set_story_flag("__test_save_target_event__" + LV1_ID, true)
	var lv1 = app.game.start_special_event(LV1_ID)
	while lv1 != null and not lv1.completed:
		app.game.choose_special_event(str(lv1.current().choices[0].id))
	app.game.finish_special_event()
	app.game.set_story_flag("__test_save_target_event__" + LV1_ID, false)

	app.game.meet_staff("doc_shiori")
	app.game.add_familiarity("doc_rei", 15)
	app.game.advance_story_to_day(8, 540)
	app.game.set_story_flag("__test_save_target_event__" + LV2_ID, true)
	var lv2 = app.game.start_special_event(LV2_ID)
	while lv2 != null and not lv2.completed:
		app.game.choose_special_event(str(lv2.current().choices[0].id))
	app.game.finish_special_event()
	app.game.set_story_flag("__test_save_target_event__" + LV2_ID, false)

	app.game.meet_staff("nurse_moe")
	app.game.meet_staff("nurse_ange")
	app.game.add_familiarity("doc_rei", 15)
	app.game.advance_story_to_day(target_day, 540)
	app.game.set_story_flag("__test_save_target_event__" + EVENT_ID, true)

func save_shot(filename: String) -> void:
	for child in app.page.get_children():
		if child is CanvasItem and str(child.name) != "EventStageEffect":
			child.show()
	await process_frame
	await RenderingServer.frame_post_draw
	var out_path := ProjectSettings.globalize_path("res://%s/%s" % [OUT_DIR, filename])
	var err: int = app.get_viewport().get_texture().get_image().save_png(out_path)
	expect(err == OK, "Saved screenshot " + out_path)

func run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path("res://" + OUT_DIR))
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/kaori_lv3_preview_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame

	# 1. Full zh_CN spring playthrough (Day 14 = 2025-04-14)
	expect(app.content.load_all("zh_CN"), "Load zh_CN content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false
	setup_lv3_ready(14)

	var event = app.game.start_special_event(EVENT_ID)
	expect(event != null, "Start miyama_03_or_god (zh_CN)")
	app.special_event_last_cg_path = ""
	app.reset_dialogue_page()
	app.show_special_event()
	await process_frame

	var captured := {}
	var steps := 0
	while not event.completed and steps < 600:
		steps += 1
		var step: Dictionary = event.current_step()
		var node: Dictionary = event.current()
		var nid := str(node.get("id", ""))

		# Verify 1.0s CG reveal hides dialogue on initial CG entry node
		if nid == "s07_014":
			app.special_event_last_cg_path = ""
			app.reset_dialogue_page()
			app.show_special_event()
			await process_frame
			var dlg = app.page.get_node_or_null("SpecialEventDialogue")
			expect(dlg != null and not dlg.visible, "Dialogue hidden during initial 1.0s CG reveal at s07_014")

		if ZH_CAPTURES.has(nid) and not captured.has(nid):
			var loc_text: String = app.special_event_localized_text(step, node)
			var pages: Array = app.authored_dialogue_pages(loc_text)
			for page_idx in range(pages.size()):
				app.dialogue_page_index = page_idx
				app.show_special_event()
				await process_frame
				var body = app.page.get_node_or_null("SpecialEventDialogue")
				if body != null:
					expect(body.get_content_height() <= body.size.y + 2, "Zero text overflow at " + nid)
			if nid == "s12_016":
				var p = app.page.get_node_or_null("CharacterPortrait")
				expect(p != null and str(p.texture.resource_path).ends_with("spring_summer_casual_v1/doc_rei/small_smile.png"), "Spring casual/small_smile resolved at s12_016")
			await save_shot(ZH_CAPTURES[nid])
			captured[nid] = true

		var choices: Array = node.get("choices", [])
		var res: Dictionary = app.game.choose_special_event(str(choices[0].id))
		expect(bool(res.get("accepted", false)), "Choice accepted at " + nid)
		if bool(res.get("event_finished", false)):
			app.game.finish_special_event()
			break

	expect(event.completed, "zh_CN playthrough completed")
	expect(captured.size() == ZH_CAPTURES.size(), "Captured all %s zh_CN screens (got %s)" % [ZH_CAPTURES.size(), captured.size()])
	app.show_special_gallery_entry(EVENT_ID)
	await process_frame
	await save_shot("09b_zh_gallery_two_chapters.png")

	# 2. English + Autumn/Winter seasonal verification (Day 247 = Monday in December -> winter casual + winter night street)
	expect(app.content.load_all("en"), "Load en content")
	app.configure_game_content()
	app.dialogue_auto_enabled = false
	setup_lv3_ready(246)
	while str(app.game.calendar_date(app.game.day_number()).weekday_id) in ["sat", "sun"]:
		app.game.advance_story_to_day(app.game.day_number() + 1, 540)

	var en_ev = app.game.start_special_event(EVENT_ID)
	expect(en_ev != null, "Start miyama_03_or_god (en winter)")
	var en_steps := 0
	while not en_ev.completed and en_steps < 600:
		en_steps += 1
		var step_en: Dictionary = en_ev.current_step()
		var node_en: Dictionary = en_ev.current()
		var nid_en := str(node_en.get("id", ""))
		if nid_en in ["s07_023", "s08_013", "s11_012", "s12_016", "s12_043"]:
			var loc_en: String = app.special_event_localized_text(step_en, node_en)
			var pages_en: Array = app.authored_dialogue_pages(loc_en)
			for p_i in range(pages_en.size()):
				app.dialogue_page_index = p_i
				app.show_special_event()
				await process_frame
			if nid_en == "s12_016":
				var wp = app.page.get_node_or_null("CharacterPortrait")
				expect(wp != null and str(wp.texture.resource_path).ends_with("winter_casual_v1/doc_rei/small_smile.png"), "Winter casual_winter/small_smile resolved at s12_016: " + (str(wp.texture.resource_path) if wp else "null"))
				await save_shot("10_en_winter_street_small_smile.png")
			elif nid_en == "s08_013":
				await save_shot("11_en_scrub_masked_choice1.png")
			elif nid_en == "s12_043":
				await save_shot("12_en_winter_station_farewell.png")
			elif nid_en == "s07_023":
				await save_shot("13_en_kasumi_mask_drowsy.png")
			elif nid_en == "s11_012":
				await save_shot("14_en_kasumi_ward_confused.png")
		var res_en: Dictionary = app.game.choose_special_event(str(node_en.choices[0].id))
		expect(bool(res_en.get("accepted", false)), "EN choice accepted at " + nid_en)
		if bool(res_en.get("event_finished", false)):
			app.game.finish_special_event()
			break

	expect(en_ev.completed, "EN winter playthrough completed")
	print("KAORI LV3 V1.2 PREVIEW CAPTURE: %s checks; %s failure(s)" % [checks, failures])
	app.queue_free()
	await process_frame
	quit(1 if failures else 0)

extends SceneTree
## Supplied data/CG integration only. No fabricated body-map geometry or player save writes.
const Content = preload('res://godot/systems/h_profile_v1_content.gd')
const Session = preload('res://godot/systems/h_profile_v1_session.gd')
const Registry = preload('res://godot/systems/free_h_registry.gd')
var checks := 0
var failures := 0
var app
func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred('run')
func run() -> void:
	var config := Registry.definition('doc_serika')
	var source := Registry.read_json(config.profile)
	var flow := Registry.read_json(config.flow)
	var labels := Registry.read_json(config.finish_labels)
	var context := Registry.read_json(config.context)
	var profile := Content.normalize(source, flow, labels, {}, context)
	expect(not profile.is_empty(), 'Supplied 1.3 / 1.3.4 bundle normalizes')
	if profile.is_empty(): quit(1); return
	expect(profile.source_asset_paths == source.assets and profile.scene == source.dialogue.scene, 'Authored assets and all legacy pools preserved')
	expect(profile.expression_atlas.is_empty() and profile.expressions == source.assets.portrait_expressions, 'Uses only character-owned expression paths')
	expect(not Registry.load_bundle('doc_serika').has('error'), 'All approved assets load in production bundle')
	var bodymap := Registry.read_json(config.bodymap)
	expect(bodymap.get('base_image') == 'assets/h/doc_serika/body_map.png' and bodymap.get('image_width') == 1024 and bodymap.get('image_height') == 1536 and bodymap.get('hotspots', {}).size() == 9, 'Calibrated map matches supplied image')
	var bad_flow := flow.duplicate(true)
	bad_flow.phase2.manual_finish.on_click.wait_until_response_advanced = false
	expect(Content.normalize(source, bad_flow, labels, {}, context).is_empty(), 'Reject finish without response acknowledgment')
	app = load('res://godot/scenes/main.tscn').instantiate(); root.add_child(app)
	await process_frame
	var han := RegEx.new(); han.compile('[\\x{3400}-\\x{9fff}]')
	for locale in ['zh_CN', 'en']:
		expect(app.content.load_all(locale), 'Load content '+locale); app.configure_game_content()
		for style in ['gentle', 'intense']:
			var session = Session.new('doc_serika', profile, 'home', '', locale)
			expect(session.phase == 'foreplay' and session.event_id.is_empty(), 'Independent repeatable session')
			expect(session.background_id('') == 'serika_home_bedroom_night', 'Own bedroom context')
			var entries: Array = session.location_entry_lines(profile.location_entry.home)
			expect(entries.size() == 4, 'Four supplied entry candidates')
			if locale == 'en':
				for line in entries: expect(han.search(str(line)) == null, 'English entry')
			var prompts := 0
			for action in Session.ACTIONS:
				for zone in Session.ZONES:
					var tier: String = source.preferences.combo_overrides.get(action+':'+zone, source.preferences.action_overrides.get(action, source.preferences.zone_defaults[zone]))
					var result: Dictionary = session.perform(action, zone)
					expect(result.accepted and result.tier == tier and not str(result.line).is_empty(), 'Authored reaction '+action+':'+zone)
					if locale == 'en': expect(han.search(str(result.line)) == null, 'English reaction')
					if result.get('show_max_prompt', false): prompts += 1
				expect(prompts == 1 and session.phase == 'foreplay' and session.excitement == 100, 'MAX once, no automatic advancement')
			if locale == 'en': expect(han.search(session.max_prompt(profile.flow.max_prompt)) == null, 'English MAX')
			expect(session.begin_h_stage(style), 'Explicit style entry')
			var lines: Array = session.h_scene_lines()
			expect(lines.size() == 6 and lines[1] != lines[2] and lines[4] != lines[5], 'Ordered six lines, no replacement')
			expect(lines[0] == session.dialogue_line('style.opening.'+style, flow.entry_style.openings[style]) and lines[3] == session.dialogue_line('style.midpoint.'+style, flow.entry_style.midpoints[style]), 'Two correct style lines')
			app.h_profile_run_kind = 'test'; app.h_profile_event_mode = false
			app.h_profile_test_session = session; app.h_profile_test_aftercare_index = 0
			for line in lines:
				app.show_sayaka_h_profile_test()
				var cg = app.page.get_node_or_null('HProfileSceneImage')
				expect(cg != null and cg.texture.resource_path == source.assets.scene_cg and cg.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, 'Actual supplied stage CG, contain')
				expect(app.page.get_node('HProfileDialogueSpeaker').text == ('Serika Misono' if locale == 'en' else '御園芹香'), 'Correct visible speaker')
				expect(app.page.get_node('HProfileDialogueText').text == line, 'Actual line displayed')
				if locale == 'en': expect(han.search(str(line)) == null, 'English phase two')
				session.advance_h_stage()
			expect(session.phase == 'h_finish_wait' and not session.h_event_completed and not session.advance_h_stage(), 'Wait for manual finish')
			var stable: String = session.h_finish_label
			app.show_sayaka_h_profile_test()
			expect(app.page.get_node('HProfileFinish').text == stable, 'Stable supplied finish label')
			expect(session.choose_h_finish() and not session.choose_h_finish() and not session.h_event_completed, 'One-shot finish response, wait for acknowledgment')
			if locale == 'en': expect(han.search(session.h_finish_response_line) == null and han.search(stable) == null, 'English finish')
			expect(session.advance_h_stage() and session.phase == 'after_cg', 'Acknowledgment enters aftercare')
			var aftercare: Array = session.aftercare_lines(profile.flow.free_aftercare_lines)
			expect(aftercare.size() == 2, 'Exactly two supplied aftercare lines')
			for i in range(aftercare.size()):
				app.h_profile_test_aftercare_index = i; app.show_sayaka_h_profile_test()
				var cg = app.page.get_node('HProfileSceneImage')
				expect(cg.texture.resource_path == source.assets.aftercare_cg and app.page.get_node('HProfileDialogueText').text == aftercare[i], 'Supplied aftercare CG and text')
				if locale == 'en': expect(han.search(str(aftercare[i])) == null, 'English aftercare')
			expect(session.finish(), 'Shared session completes')
			app.h_profile_test_session = null
		app.show_map(false)
		app.show_free_h_booking_response('doc_serika', 'home', 'imaging')
		expect(app._free_h_place_label('doc_serika', 'home') == ('Serika’s home' if locale == 'en' else '芹香家'), 'Home belongs to Serika')
		app.show_map(false)
		app.game.meet_staff('doc_serika')
		app.game.relation_for('doc_serika').unlocked_benefits = ['unlock_intimacy_events']
		app.game.special_event_completion_counts['serika_lv4_stay'] = 1
		app.game.special_event_completion_days['serika_lv4_stay'] = 120
		expect(app.game.free_h_unlocked('doc_serika'), 'Completed milestone and existing benefit unlock ready content')
	print('SERIKA FREE H: ',checks,' checks; ',failures,' failures; all six portraits available')
	quit(1 if failures else 0)

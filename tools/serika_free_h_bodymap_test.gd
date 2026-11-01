extends SceneTree
## Asset geometry and real UI input routing only; no saves or production unlock.
const Content = preload('res://godot/systems/h_profile_v1_content.gd')
const Session = preload('res://godot/systems/h_profile_v1_session.gd')
const Registry = preload('res://godot/systems/free_h_registry.gd')
var checks := 0
var failures := 0
func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _initialize() -> void:
	call_deferred('run')
func run() -> void:
	var config := Registry.definition('doc_serika')
	var bodymap := Registry.read_json(config.bodymap)
	var profile := Content.normalize(Registry.read_json(config.profile), Registry.read_json(config.flow), Registry.read_json(config.finish_labels), {}, Registry.read_json(config.context))
	var samples := {
		'lips': [Vector2(520,350)], 'cheeks': [Vector2(435,290),Vector2(613,330)],
		'neck': [Vector2(520,462)], 'breasts': [Vector2(400,650),Vector2(600,650)],
		'nipples': [Vector2(326,606),Vector2(695,615)], 'navel': [Vector2(511,970)],
		'torso_other': [Vector2(510,850),Vector2(500,550)], 'genitals': [Vector2(510,1320)],
		'thighs': [Vector2(250,1210),Vector2(770,1210)]
	}
	var misses := [Vector2(100,100),Vector2(800,400),Vector2(760,820),Vector2(276,489),Vector2(1000,1500),Vector2(-10,100),Vector2(1030,100)]
	var app = load('res://godot/scenes/main.tscn').instantiate()
	root.add_child(app)
	await process_frame
	expect(app.content.load_all('zh_CN'), 'Content loads')
	app.configure_game_content()
	var image_size := Vector2(1024,1536)
	var polygons := 0
	for zone in Session.ZONES:
		expect(bodymap.hotspots.has(zone), 'Registered region '+zone)
		for polygon in bodymap.hotspots[zone]:
			polygons += 1
			var valid: bool = polygon.size() >= 3
			for point in polygon:
				valid = valid and point.size() == 2 and point[0] >= 0 and point[0] <= 1 and point[1] >= 0 and point[1] <= 1
			expect(valid, 'Normalized valid polygon '+zone)
	expect(polygons == 14, 'Fourteen polygons')
	for zone in samples:
		for pixel in samples[zone]:
			var session = Session.new('doc_serika', profile, 'home', '', 'zh_CN')
			app.h_profile_test_session = session
			app.h_profile_test_bodymap = bodymap
			app.h_profile_test_action = 'caress'
			app.h_profile_test_last_result = {}
			app.h_profile_run_kind = 'free'
			app.h_profile_event_mode = false
			app.h_profile_test_max_prompt_visible = false
			app.show_sayaka_h_profile_test()
			var body = app.page.get_node('HProfileBodyMap')
			var portrait = app.page.get_node('HProfileExpression')
			expect(body.texture.resource_path == 'res://assets/h/doc_serika/body_map.png' and body.texture.get_size() == image_size, 'Own body texture, actual size')
			expect(body.size == Vector2(340,510) and body.stretch_mode == TextureRect.STRETCH_KEEP_ASPECT_CENTERED, 'Uncropped display geometry')
			expect(portrait.texture != null and portrait.texture.resource_path == 'res://assets/h/doc_serika/portrait_neutral.png', 'Own approved neutral')
			expect(session.hit_test(pixel / image_size, bodymap) == zone, 'Pixel geometry '+zone)
			var event := InputEventMouseButton.new()
			event.button_index = MOUSE_BUTTON_LEFT
			event.pressed = true
			event.position = pixel / image_size * body.size
			body.gui_input.emit(event)
			expect(app.h_profile_test_last_result.get('accepted', false) and app.h_profile_test_last_result.get('zone') == zone, 'Real UI input routes to '+zone)
	var session = Session.new('doc_serika', profile, 'home', '', 'zh_CN')
	for pixel in misses:
		expect(session.hit_test(pixel / image_size, bodymap).is_empty(), 'Noninteractive background '+str(pixel))
	expect(Session.point_to_uv(Vector2(10,10), Rect2(70,160,340,510)) == Vector2(-1,-1), 'Outside image rejected')
	app.h_profile_test_session = null
	app.show_map(false)
	expect(not Registry.load_bundle('doc_serika').has('error'), 'Complete approved asset bundle loads')
	print('SERIKA BODYMAP: ', checks, ' checks; ', failures, ' failures; native visual review not performed')
	quit(1 if failures else 0)

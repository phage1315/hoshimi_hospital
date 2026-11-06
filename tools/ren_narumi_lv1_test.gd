extends SceneTree
## Isolated runtime regression for the two authored fixed-VN Lv1 events.

const IDS := ["ren_lv1_night_ward_1", "narumi_lv1_beyond_the_resume"]
const ACTORS := ["nurse_haru", "doc_aoi"]
const COUNTS := [243, 202]
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

func no_inner(value: Variant) -> bool:
	if value is Dictionary:
		for key in value:
			if str(key) in ["node_id", "step_index", "choices", "last_choice", "action_log"]:
				return false
			if not no_inner(value[key]):
				return false
	elif value is Array:
		for item in value:
			if not no_inner(item):
				return false
	return true

func test_event(index: int, locale: String) -> void:
	var id: String = IDS[index]
	var actor_id: String = ACTORS[index]
	var g = app.game
	var definition: Dictionary = g.character_event_definitions.get(id, {})
	expect(not definition.is_empty(), "Registered event " + id)
	if definition.is_empty():
		return
	expect(definition.category == "bond" and definition.target_level == 1, "Only Lv1 relationship reward " + id)
	expect(definition.nodes.size() == COUNTS[index], "Complete node count " + id)
	expect(definition.trigger_mode == ("after_work" if index == 0 else "location"), "Natural entry mode " + id)
	g.reset()
	expect(not g.character_event_available(definition), "Unmet actor blocked " + id)
	g.meet_staff(actor_id)
	g.relation_for(actor_id).familiarity = 9
	expect(not g.character_event_available(definition), "Familiarity 9 blocked " + id)
	g.relation_for(actor_id).familiarity = 10
	expect(g.character_event_available(definition), "Familiarity 10 allowed " + id)
	expect(g.prepare_character_event_test_save(id), "In-memory test fixture " + id)
	expect(g.character_event_available(definition), "Fixture eligible " + id)
	if index == 0:
		expect(str(g.next_after_work_character_event().get("id", "")) == id, "Ren appears at end of workday")
	else:
		expect(str(g.next_character_event_at("shared_doctors_office").get("id", "")) == id, "Narumi appears at surgical office")
	var surgery_count: int = g.completed_surgeries_total
	var before_day: int = g.day_number()
	var initial_staff_patient: Dictionary = g.active_staff_patient.duplicate(true)
	if index == 0:
		app.request_end_workday()
	else:
		app.show_location("shared_doctors_office")
	var event = g.character_events.get(id)
	expect(event != null, "Starts " + id)
	if event == null:
		return
	expect(g.active_character_event_id == id and app.screen == "character_event", "Natural UI entry " + id)
	for i in range(definition.nodes.size()):
		var node: Dictionary = event.current()
		var expected: Dictionary = definition.nodes[i]
		expect(str(node.id) == str(expected.id), "Sequential node %s %s" % [id, i])
		expect(g.relationship_level(actor_id) == 0, "No early Lv1 settlement %s %s" % [id, i])
		expect(not g.can_save_progress() and g.snapshot().is_empty(), "No event save %s %s" % [id, i])
		if locale == "en":
			expect(not str(node.text).contains("「") and not str(node.text).contains("【七") and not str(node.text).contains("【神"), "English loaded %s %s" % [id, i])
		app.show_character_event()
		var background = app.page.get_node_or_null("SceneBackground")
		expect(background != null and background.texture != null, "Background loaded %s %s" % [id, i])
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if bool(node.hide_portrait):
			expect(portrait == null, "Narrator/other actor has no borrowed portrait %s %s" % [id, i])
		else:
			expect(portrait != null and portrait.texture != null, "Speaking actor portrait %s %s" % [id, i])
		if index == 0:
			expect(not app.page.get_node("CalendarHeader").visible, "Night scene hides compressed shift clock")
		if i + 1 == definition.nodes.size():
			app.choose_character_event(str(node.choices[0].id))
		else:
			expect(g.choose_character_event(str(node.choices[0].id)), "Advance %s %s" % [id, i])
	expect(event.completed and g.relationship_level(actor_id) == 1, "Lv1 settled once at end " + id)
	expect(g.relation_for(actor_id).rank_history.count(id) == 1, "One Lv1 rank fact " + id)
	expect(event.settled_minutes == int(definition.minutes), "Exact historical event duration " + id)
	if index == 0:
		expect(g.day_number() == before_day + 1, "Midnight story resolves into one next day")
	expect(g.completed_surgeries_total == surgery_count and g.active_staff_patient == initial_staff_patient, "No clinical runner or staff patient mutation " + id)
	expect(g.start_character_event(id) == null, "Completed event cannot restart " + id)
	if index == 0:
		expect(app.screen == "day_transition", "Night event enters next-day transition")
		app.continue_after_day_transition()
		expect(app.screen == "map", "Night event returns to hospital map")
	else:
		expect(app.screen == "character_event_complete", "Completion screen " + id)
	app.show_map()
	expect(g.can_save_progress(), "Save only after map boundary " + id)
	var save: Dictionary = g.snapshot()
	expect(not save.is_empty() and no_inner(save), "No inner state in boundary save " + id)
	var settled_elapsed: int = g.elapsed()
	expect(g.restore(JSON.parse_string(JSON.stringify(save))), "Boundary load " + id)
	expect(g.elapsed() == settled_elapsed and g.relationship_level(actor_id) == 1 and not g.character_event_available(definition), "No replay after load " + id)

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	app.saves.path = "/private/tmp/ren_narumi_lv1_unused_%s.json" % OS.get_process_id()
	root.add_child(app)
	await process_frame
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Content loads " + locale)
		app.configure_game_content()
		for index in range(IDS.size()):
			test_event(index, locale)
	print("REN NARUMI LV1: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)

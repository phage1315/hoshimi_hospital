extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")
const Game = preload("res://godot/systems/game_state.gd")
const Preop = preload("res://godot/systems/preop_session.gd")

var checks := 0
var failures := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var maya: Dictionary = content.find_record("staff", "visiting_maya")
	expect(not maya.is_empty() and maya.rank == "访问研究医／研究协力", "Maya visiting-research profile is missing")
	expect(maya.skills == {"surgery": 28, "diagnostics": 62, "teamwork": 82, "patient_care": 58, "instrument_handling": 91, "calmness": 76}, "Maya skill profile changed")
	expect("relationship_progression_locked" in maya.flags and "no_romance_route" in maya.flags and "no_adult_route" in maya.flags, "Maya route exclusions are incomplete")
	for portrait_key in ["white_coat/neutral", "scrubs/neutral", "sterile/neutral"]:
		var portrait := load("res://" + str(maya.visuals.portraits[portrait_key])) as Texture2D
		expect(portrait != null and portrait.get_size() == Vector2(1024, 1536), "Maya half-body portrait missing or wrong size: " + portrait_key)
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	var intro: Dictionary = game.character_event_definitions.intro_visiting_maya_waveform_error
	expect(not game.character_event_available(intro), "Maya appeared before the midgame gate")
	game.advance_story_to_day(60, 540)
	game.completed_surgeries_total = 8
	expect(game.character_event_available(intro), "Maya introduction did not unlock in midgame")
	var event = game.start_character_event("intro_visiting_maya_waveform_error")
	expect(event != null, "Maya introduction could not start")
	if event != null:
		while not event.completed:
			game.choose_character_event(event.current().choices[0].id)
	expect(game.staff_is_met("visiting_maya") and game.staff_can_join_surgery_team("visiting_maya"), "Maya was not unlocked as a special assistant")
	game.complete_rank_up("visiting_maya", "maya_test_lv1", 1, "forbidden_benefit")
	expect(game.relationship_level("visiting_maya") == 0 and game.next_rank_slot("visiting_maya").is_empty(), "Maya advanced beyond acquaintance")
	expect(not game.relation_for("visiting_maya").unlocked_benefits.has("forbidden_benefit"), "Maya received a forbidden relationship benefit")
	var prep = Preop.new(content.collections.preops[0], content.collections.staff, content.collections.surgeries, content.collections.patients, ["visiting_maya"], true)
	prep.procedure_id = "surgery_appendix"
	expect(prep.assignment_response("assistant_surgeon", "visiting_maya").contains("腹部手术"), "Maya abdominal assistant dialogue was not selected")
	expect(prep.staff_action_response("visiting_maya", "confirm_assistant_role", "fallback").contains("机器"), "Maya technical-assistant role dialogue was not selected")
	print("MAYA CHARACTER: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

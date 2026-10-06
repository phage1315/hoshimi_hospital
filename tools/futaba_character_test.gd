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

func finish_event(game: RefCounted, event: RefCounted) -> void:
	while event != null and not event.completed:
		game.choose_character_event(event.current().choices[0].id)

func run() -> void:
	var content = Loader.new()
	expect(content.load_all(), "Content load failed")
	var futaba: Dictionary = content.find_record("staff", "visiting_futaba")
	expect(not futaba.is_empty() and futaba.age == 26, "Adult Futaba profile missing")
	expect(futaba.skills == {"surgery": 34, "diagnostics": 91, "teamwork": 76, "patient_care": 74, "instrument_handling": 70, "calmness": 68}, "Futaba skill profile changed")
	expect("relationship_progression_locked" in futaba.flags and "no_romance_route" in futaba.flags and "no_adult_route" in futaba.flags, "Futaba route exclusions are incomplete")
	for portrait_key in ["white_coat/neutral", "scrubs/neutral", "sterile/neutral"]:
		var portrait := load("res://" + str(futaba.visuals.portraits[portrait_key])) as Texture2D
		expect(portrait != null and portrait.get_size() == Vector2(1024, 1536), "Futaba half-body portrait missing or wrong size: " + portrait_key)
	var game = Game.new()
	game.configure(content.collections.encounters, content.collections.preops, content.collections.staff, content.collections.time_events, content.collections.surgeries, content.collections.patients, content.collections.relationships, content.collections.character_events)
	game.advance_story_to_day(60, 540)
	game.completed_surgeries_total = 8
	var futaba_intro: Dictionary = game.character_event_definitions.intro_visiting_futaba_body_does_not_believe
	expect(not game.character_event_available(futaba_intro), "Futaba appeared before Maya's joint-research introduction")
	finish_event(game, game.start_character_event("intro_visiting_maya_waveform_error"))
	expect(game.character_event_available(futaba_intro), "Futaba did not unlock after Maya's introduction")
	finish_event(game, game.start_character_event("intro_visiting_futaba_body_does_not_believe"))
	expect(game.staff_is_met("visiting_futaba") and game.staff_can_join_surgery_team("visiting_futaba"), "Futaba was not unlocked as an assistant")
	game.complete_rank_up("visiting_futaba", "forbidden_lv1", 1, "forbidden_benefit")
	expect(game.relationship_level("visiting_futaba") == 0 and game.next_rank_slot("visiting_futaba").is_empty(), "Futaba advanced beyond acquaintance")
	var prep = Preop.new(content.collections.preops[0], content.collections.staff, content.collections.surgeries, content.collections.patients, ["visiting_futaba"], true)
	expect(prep.assignment_response("assistant_surgeon", "visiting_futaba").contains("我负责看她为什么"), "Futaba assistant assignment dialogue was not selected")
	expect(prep.staff_action_response("visiting_futaba", "confirm_assistant_role", "fallback").contains("脑子也是器官"), "Futaba mind-body role dialogue was not selected")
	print("FUTABA CHARACTER: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

extends Node
const StaffPatientController = preload("res://godot/systems/advanced_staff_patient.gd")
## Presentation only. No playback state is included in GameState or saves.
const TRACKS := {
	"station": "Sunlight_on_the_Chart", "triage": "triage", "roof": "roof", "advanced_hope": "Midnight_on_the_Fire_Escape", "prep": "prep", "lounge": "lounge", "title": "title_screen", "spring": "spring_theme", "summer": "summer_theme",
	"autumn": "autumn_theme", "winter": "winter_theme", "surgery": "surgery_2", "surgery_1": "surgery_1",
	"advanced_surgery": "advance_surgery_1", "night": "night_theme", "ending": "ending_theme",
}
const LOCATION_TRACKS := {"station": "station", "lounge": "lounge", "rooftop": "roof"}
const BACKGROUND_TRACKS := {"nurses_station": "station", "staff_lounge": "lounge", "rooftop": "roof"}
var overrides: Dictionary = {"events": {}, "nodes": {}, "bgm_keys": {}}
const ORDINARY_SURGERY_TRACKS := ["surgery_1", "surgery"]
const BGM_MASTER_TRIM_DB := -4.5
# Independent presentation RNG: never consume the gameplay random sequence.
var surgery_rng := RandomNumberGenerator.new()
var surgery_session_id := 0
var surgery_track := ""
var current_id := ""
var players: Array[AudioStreamPlayer] = []
var active_index := 0
var fade: Tween
var fade_seconds := 1.2
var volume := 0.55
var preferences_path := ""

func _ready() -> void:
	surgery_rng.randomize()
	var config = JSON.parse_string(FileAccess.get_file_as_string("res://data/audio/bgm_overrides.json"))
	if valid_overrides(config):
		overrides = config
	else:
		push_error("Invalid data/audio/bgm_overrides.json: expected events/nodes/bgm_keys maps of registered track IDs (or empty string for silence)")
	if AudioServer.get_bus_index("BGM") < 0:
		AudioServer.add_bus()
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "BGM")
	for i in range(2):
		var player := AudioStreamPlayer.new()
		player.bus = "BGM"
		add_child(player)
		players.append(player)
	set_volume(volume)

func configure_preferences(path: String) -> void:
	preferences_path = path
	var config := ConfigFile.new()
	if config.load(path) == OK:
		set_volume(float(config.get_value("audio", "bgm_volume", 0.55)))

func set_volume(value: float, persist: bool = false) -> void:
	volume = clampf(value, 0.0, 1.0)
	var bus := AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_mute(bus, volume <= 0.0)
	AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.0001)) + BGM_MASTER_TRIM_DB)
	if persist and not preferences_path.is_empty():
		var config := ConfigFile.new()
		config.load(preferences_path)
		config.set_value("audio", "bgm_volume", volume)
		if config.save(preferences_path) != OK:
			push_error("Could not save BGM volume preference")

static func stream_for(id: String) -> AudioStreamMP3:
	if not TRACKS.has(id): return null
	var stream := load("res://assets/audio/bgm/%s.mp3" % TRACKS[id]) as AudioStreamMP3
	if stream == null: return null
	stream = stream.duplicate() as AudioStreamMP3
	stream.loop = id != "ending"
	return stream

func play_track(id: String) -> void:
	if id == current_id: return
	if not id.is_empty() and not TRACKS.has(id):
		push_error("Unknown BGM: " + id)
		return
	var stream: AudioStreamMP3 = null
	if not id.is_empty():
		stream = stream_for(id)
		if stream == null:
			push_error("Cannot load BGM: " + id)
			return
	current_id = id
	if fade != null: fade.kill()
	var outgoing := players[active_index]
	active_index = 1 - active_index
	var incoming := players[active_index]
	incoming.stop()
	fade = create_tween().set_parallel(true)
	fade.tween_property(outgoing, "volume_db", -60.0, fade_seconds)
	fade.tween_callback(outgoing.stop).set_delay(fade_seconds)
	if stream != null:
		incoming.stream = stream
		incoming.volume_db = -60.0
		incoming.play()
		fade.tween_property(incoming, "volume_db", 0.0, fade_seconds)

static func season(month: int) -> String:
	if month in [3, 4, 5]: return "spring"
	if month in [6, 7, 8]: return "summer"
	if month in [9, 10, 11]: return "autumn"
	return "winter"

func ordinary_surgery_track(app) -> String:
	var prep = app.game.preops.get(app.game.active_preop_id)
	var session_id: int = prep.get_instance_id() if prep != null else 0
	if surgery_track.is_empty() or (session_id != 0 and session_id != surgery_session_id):
		surgery_session_id = session_id
		surgery_track = ORDINARY_SURGERY_TRACKS[surgery_rng.randi_range(0, ORDINARY_SURGERY_TRACKS.size() - 1)]
	return surgery_track

func advanced_track(controller) -> String:
	if controller == null: return ""
	var fallback := season(int(controller.game.calendar_date(controller.day()).month))
	# Failure overrides the operation track as soon as the result is known.
	if controller.session != null:
		if controller.session.finished and not controller.session.success: return ""
		return "advanced_surgery"
	var facts: Dictionary = controller.state()
	var outcome: Dictionary = facts.get("outcome", {})
	var appointment: Dictionary = facts.get("appointment", {})
	if not outcome.is_empty():
		if not bool(outcome.get("success", false)): return ""
		return "advanced_hope" if controller.day() >= int(appointment.get("review_day", 2147483647)) else fallback
	if controller.last_summary.has("case_id"):
		return "advanced_hope" if bool(controller.last_summary.get("success", false)) else ""
	# Staff-patient night chapters are outside the requested Day 1 consultation.
	if controller.story_phase == "failure": return ""
	if controller.story_phase in ["night", "dark", "after"]: return fallback
	if controller is StaffPatientController:
		if controller.night_choice or controller.transition_pending: return fallback
	if not appointment.is_empty():
		return "advanced_hope" if controller.day() == int(appointment.get("intake_day", -1)) else fallback
	return "advanced_hope" if controller.eligible() else fallback

static func valid_overrides(config: Variant) -> bool:
	if not config is Dictionary: return false
	for section in ["events", "nodes", "bgm_keys"]:
		if not config.get(section) is Dictionary: return false
		for value in config[section].values():
			if not value is String or (not value.is_empty() and not TRACKS.has(value)): return false
	return true

func event_context(app) -> Dictionary:
	var event: RefCounted = null
	match str(app.screen):
		"character_event", "character_event_reward", "character_event_complete":
			event = app.game.character_events.get(app.game.active_character_event_id)
		"gallery_replay": event = app.gallery_replay_event
		"special_event", "special_event_complete": event = app.game.active_special_event
		"special_gallery_replay": event = app.special_event_gallery_replay
		"daydream_playback": event = app.daydream_view.session
		"micro_event": event = app.game.micro_events.get(app.game.active_micro_event_id)
	if event != null:
		var node: Dictionary = event.current() if event.has_method("current") else {}
		var step: Dictionary = event.current_step() if event.has_method("current_step") else {}
		return {"event_id": str(event.definition.get("id", "")), "step_id": str(step.get("id", "")), "node_id": str(node.get("id", "")), "bgm_key": str(node.get("bgm_key", step.get("bgm_key", event.definition.get("bgm_key", ""))))}
	if app.screen == "time_event_result" and is_instance_valid(app.page):
		return {"event_id": str(app.page.get_meta("music_event_id", ""))}
	return {}

func event_override(context: Dictionary) -> Dictionary:
	var event_id := str(context.get("event_id", ""))
	var node_key := event_id + "/" + str(context.get("node_id", ""))
	var step_id := str(context.get("step_id", ""))
	var scoped_key := event_id + "/" + step_id + "/" + str(context.get("node_id", ""))
	if not step_id.is_empty() and overrides.nodes.has(scoped_key): return {"found": true, "track": overrides.nodes[scoped_key]}
	if overrides.nodes.has(node_key): return {"found": true, "track": overrides.nodes[node_key]}
	if overrides.events.has(event_id): return {"found": true, "track": overrides.events[event_id]}
	var key := str(context.get("bgm_key", ""))
	if overrides.bgm_keys.has(key): return {"found": true, "track": overrides.bgm_keys[key]}
	return {"found": false}

func location_fallback(app) -> String:
	if app.screen == "location":
		return str(LOCATION_TRACKS.get(app.displayed_location_id, season(int(app.game.calendar_date().month))))
	# Use the actual rendered background: events can move away from their entry location.
	return str(BACKGROUND_TRACKS.get(app.displayed_background_id, season(int(app.game.calendar_date().month))))

func track_for(app) -> String:
	var screen: String = app.screen
	# Preserve the draw through overlays/results; retire it after leaving the case.
	if app.game.preops.get(app.game.active_preop_id) == null and screen not in ["preop", "or_table_palpation", "surgery_video", "surgery_cg", "surgery_sweep_result", "save_slots", "staff_role_reward"]:
		surgery_session_id = 0
		surgery_track = ""
	if screen in ["save_slots", "special_event_blackout"]: return current_id
	if screen == "title": return "title"
	if screen in ["opening_chapter", "dialogue"]: return "spring"
	if screen in ["encounter", "examination_cg", "referral"]: return "triage"
	if screen in ["after_work_walk", "day_transition"]: return "night"
	if screen == "advanced_referral": return advanced_track(app.advanced_controller)
	var override := event_override(event_context(app))
	if override.found: return str(override.track)
	# Authored tutorial surgery also uses the advanced track, without rewriting nodes.
	if screen in ["special_event", "special_gallery_replay"]:
		var event = app.game.active_special_event if screen == "special_event" else app.special_event_gallery_replay
		if event != null:
			var node: Dictionary = event.current()
			if str(event.definition.get("id", "")) == "advanced_referral_tutorial_chisato":
				var chapter: String = str(event.current_step().get("id", ""))
				if chapter in ["advanced_referral_tutorial_chisato_day1", "advanced_referral_tutorial_chisato_day3"]: return "advanced_hope"
			if str(node.get("presentation", "")) == "advanced_surgery": return "advanced_surgery"
		return location_fallback(app)
	if screen in ["surgery_video", "surgery_cg", "surgery_sweep_result"]: return ordinary_surgery_track(app)
	if screen == "preop_transition_video": return "prep"
	if screen in ["preop", "or_table_palpation", "ward_preparation_cg"]:
		var prep = app.game.preops.get(app.game.active_preop_id)
		if prep == null: return ""
		# Scene entry, not incision, is the authored boundary for the surgery track.
		if str(prep.current().get("scene", "")) == "operating_room": return ordinary_surgery_track(app)
		return "prep"
	return location_fallback(app)

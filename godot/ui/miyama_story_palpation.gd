extends RefCounted
## Transient presentation only. Never registered in GameState.preops or saved.
const Preop = preload("res://godot/systems/preop_session.gd")
const View = preload("res://godot/ui/preop_view.gd")
var app: Control
var event: RefCounted
var replay := false
var prep: RefCounted

static func owns(session: RefCounted) -> bool:
	return session != null and not session.completed and str(session.definition.id) == "miyama_01_safety_pin" and str(session.current().id) == "palpation_placeholder"

static func open_if_needed(host: Control, session: RefCounted, is_replay: bool) -> bool:
	if not owns(session):
		return false
	var controller = load("res://godot/ui/miyama_story_palpation.gd").new()
	controller.app = host
	controller.event = session
	controller.replay = is_replay
	controller.prep = Preop.new({"surgery_id": "surgery_exploratory_laparotomy", "patient_id": "", "stages": [], "start": "or_table_palpation", "initial_anxiety": 0, "_locale": host.content.localizer.locale}, [])
	host.or_table_palpation_tool = "palpation"
	host.or_table_palpation_intensity = "standard"
	controller.render()
	return true

func active() -> bool:
	return owns(event) and app.screen == "or_table_palpation" and event == (app.special_event_gallery_replay if replay else app.game.active_special_event)

func render() -> void:
	View.render_or_table_palpation(app, prep, {"name": app.tx("ui.miyama_palpation.patient", "患者")}, self)

func select_tool(tool: String) -> void:
	if not active() or tool != "palpation":
		return
	app.or_table_palpation_tool = "palpation"
	render()

func select_intensity(intensity: String) -> void:
	if not active() or intensity not in ["light", "standard", "deep"]:
		return
	app.or_table_palpation_intensity = intensity
	app.or_table_palpation_tool = "palpation"
	render()

func touch(region: String) -> void:
	if not active() or app.or_table_palpation_tool != "palpation" or region not in ["abdomen", "breast", "genital"]:
		return
	if region == "abdomen":
		prep.feedback = app.tx("ui.miyama_palpation.inconclusive", "患者紧绷，疼痛定位和腹壁反应无法可靠解释。")
		prep.feedback_speaker = "narrator"
	else:
		# Reuse the existing embarrassed/protesting response, without cycling
		# into other response variants or applying clinical effects/rewards.
		prep.feedback = prep.or_table_palpation_response(region, app.or_table_palpation_intensity, 0)
		prep.feedback_speaker = "patient"
	render()

func finish() -> void:
	if not active():
		return
	if replay:
		app.choose_special_gallery_replay("skip_palpation")
	else:
		app.choose_special_event("skip_palpation")

func exit_replay() -> void:
	if active() and replay:
		app.show_special_gallery_entry(str(event.definition.id))

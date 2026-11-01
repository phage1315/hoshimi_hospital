extends SceneTree

const Preop = preload("res://godot/systems/preop_session.gd")
const View = preload("res://godot/ui/preop_view.gd")
var checks := 0
var failures := 0
var app
var content

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func fixture(care: int, nurse_id: String = "nurse_yui"):
	var staff: Array = content.collections.staff.duplicate(true)
	for person in staff:
		if person.id == nurse_id:
			person.skills.patient_care = care
	var p = Preop.new(content.find_record("preops", "preop_sora").duplicate(true), staff, content.collections.surgeries, content.collections.patients)
	p.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": nurse_id}
	p.stage_id = "preparation"
	p.fear = 30
	p.dignity = 100
	return p

func act(p, id: String) -> void:
	expect(p.apply({"kind": "action", "id": id}), "Accepted " + id)

func run() -> void:
	app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	content = app.content
	var examples := {0:20, 6:20, 8:20, 19:20, 20:20, 21:15, 30:15, 31:10, 40:10, 41:5, 50:5, 51:0, 59:0, 60:0, 85:0, 100:0}
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		for care in examples:
			var p = fixture(care)
			act(p, "perform_preparation")
			var penalty: int = examples[care]
			expect(p.fear == 30 + penalty and p.dignity == 100 - penalty, "Actual preparation effects at care %s / %s" % [care, locale])
			expect(p.stage_id == "prepared" and p.minutes == 5, "Normal completion and unchanged duration")
			expect(p.showing_ward_care_penalty() == (penalty > 0), "Warning only for nonzero penalty")
			var before: Array = [p.fear, p.dignity, p.minutes, p.feedback]
			expect(not p.apply({"kind": "action", "id": "perform_preparation"}), "Cannot execute twice")
			expect(before == [p.fear, p.dignity, p.minutes, p.feedback], "Duplicate attempt cannot charge or change response")
			View.render(app, p)
			var rendered: String = app.page.get_node("PreopRecordText").text
			var speaker: String = app.page.get_node("PreopRecordSpeaker").text
			var marker := "The patient seems quite worn out by the ordeal..." if locale == "en" else "患者似乎被折腾得够呛。。。"
			expect(rendered.contains(marker) == (penalty > 0), "Rendered localized narration")
			if penalty > 0:
				expect(speaker != p.roster.nurse_yui.name and rendered.contains(p.staff_display_name(p.roster.nurse_yui.name)), "Mixed record retains nurse attribution and separates narration: %s / %s / %s" % [speaker, rendered, p.roster.nurse_yui.name])
			if locale == "en":
				var han := RegEx.new()
				han.compile("[\\x{3400}-\\x{9fff}]")
				expect(han.search(rendered + speaker) == null, "English display has no Chinese")
			act(p, "to_changing")
			expect(not p.showing_ward_care_penalty(), "Warning does not leak to next stage")
		# A different canonical nurse gets exactly the same low-care effect.
		var other = fixture(8, "nurse_iwasaki_rumi")
		act(other, "perform_preparation")
		expect(other.fear == 50 and other.dignity == 80, "No character-name dependency")
		var bounds = fixture(0)
		bounds.fear = 95
		bounds.dignity = 5
		act(bounds, "perform_preparation")
		expect(bounds.fear == 100 and bounds.dignity == 0, "Patient stats clamp at bounds")
		var optional = fixture(8)
		optional.selected_preparations.assign(["explain_again", "company"])
		act(optional, "perform_preparation")
		expect(optional.fear == 50 and optional.dignity == 80 and optional.minutes == 11, "Optional preparations do not multiply penalty or change timing")
		var expert = fixture(85)
		act(expert, "perform_preparation")
		expect(expert.anxiety == 1, "Existing high-care reassurance retained")
		var manual_low = fixture(8)
		var manual_high = fixture(60)
		for p in [manual_low, manual_high]:
			for id in ["begin_manual_ward_preparation", "ward_enema", "ack_ward_enema", "ward_skin_prep", "ack_ward_skin_prep", "ward_surgical_cap", "complete_manual_ward_preparation"]:
				act(p, id)
			expect(p.stage_id == "prepared" and not p.showing_ward_care_penalty(), "Manual route finishes without warning")
		expect(manual_low.fear == manual_high.fear and manual_low.dignity == manual_high.dignity and manual_low.minutes == manual_high.minutes, "Low nurse care does not punish player-performed preparation")
	print("WARD CARE PENALTY: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

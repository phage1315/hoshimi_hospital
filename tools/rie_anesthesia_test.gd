extends SceneTree

var checks := 0
var failures := 0

class FakePreparation:
	extends RefCounted
	var definition := {"patient_id": "patient_rie"}

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	expect(app.anesthesia_splash_kind_for_action("choose_general") == "general_pre_induction", "General anesthesia choice did not map to the pre-induction CG")
	expect(app.anesthesia_splash_kind_for_action("induction_reassure") == "general", "Induction response no longer maps to the completed-induction CG")
	expect(app.anesthesia_splash_kind_for_action("choose_epidural") == "epidural", "Epidural splash mapping changed")
	app.base("测试", "", true)
	app.show_anesthesia_splash(FakePreparation.new(), "general_pre_induction")
	var overlay: Control = app.page.get_node_or_null("GeneralAnesthesiaPreInductionSplash")
	expect(overlay != null, "Rie's pre-induction overlay did not open")
	var cg: TextureRect = app.page.find_child("GeneralAnesthesiaPreInductionSplashCG", true, false)
	expect(cg != null and cg.texture.resource_path.ends_with("/anesthesia_v1/patient_rie/general_pre_induction.png"), "Rie's pre-induction overlay used the wrong CG")
	var continue_button: Button = app.page.find_child("AnesthesiaSplashContinue", true, false)
	expect(continue_button != null and continue_button.text.contains("继续诱导"), "Rie's pre-induction overlay has the wrong continuation")
	if continue_button != null:
		continue_button.pressed.emit()
	await process_frame
	expect(app.page.get_node_or_null("GeneralAnesthesiaPreInductionSplash") == null, "Rie's pre-induction overlay did not close")
	print("RIE ANESTHESIA: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

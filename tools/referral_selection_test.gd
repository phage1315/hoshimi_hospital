extends SceneTree

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
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var queue: Array[String] = ["patient_sora"]
	for patient in app.content.collections.patients:
		if str(patient.id) != "patient_sora":
			queue.append(str(patient.id))
	app.game.patient_queue.assign(queue)
	expect(not app.game.refer_current_patient("doc_rei"), "An unknown doctor accepted a referral through the state API")
	expect(app.game.last_error.contains("已经认识"), "Unknown-doctor referral did not explain the acquaintance requirement")
	app.game.meet_staff("doc_rei")
	app.show_referral("patient_sora")
	var picker := app.page.get_node_or_null("ReferralDoctorPicker") as OptionButton
	var confirm := app.page.get_node_or_null("ReferralConfirm") as Button
	expect(picker != null and confirm != null, "Referral dropdown or confirmation button is missing")
	if picker != null and confirm != null:
		expect(picker.item_count == 2, "Referral dropdown did not contain exactly the placeholder and one known doctor")
		expect(str(picker.get_item_metadata(1)) == "doc_rei", "Known doctor is missing from the referral dropdown")
		expect(confirm.disabled, "Referral confirmation started enabled")
		picker.select(1)
		picker.item_selected.emit(1)
		expect(not confirm.disabled, "Referral confirmation did not enable after selection")
		confirm.pressed.emit()
		expect(app.game.referral_doctor("patient_sora") == "doc_rei", "Selected doctor did not receive the referral")
		expect(app.game.current_patient_id() != "patient_sora", "Referral did not advance the waiting patient")
	app.queue_free()
	print("REFERRAL SELECTION: %d checks; %d failure(s)" % [checks, failures])
	quit(1 if failures else 0)

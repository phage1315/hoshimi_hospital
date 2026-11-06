extends "res://tools/advanced_surgery_test.gd"
const Ready = preload("res://tools/staff_patient_lv5_readiness.gd")
const StaffEpisode = preload("res://godot/systems/advanced_staff_patient.gd")
const Setup = preload("res://godot/systems/advanced_staff_patient_test_setup.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")

func run() -> void:
	var g = new_game()
	var texts: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/stories.json"))
	var assets: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/assets.json"))
	var profiles := Registry.profiles()
	var report: Array = []
	expect(texts.actors.size() == 24, "All V2.3 source routes preloaded")
	for actor in texts.actors:
		var c = StaffEpisode.new(g, actor)
		c.first_night = true
		# Compile every chapter through the real episode adapter, even future routes.
		for phase in Ready.PHASES:
			c.chapter(phase)
			var chapter: Dictionary = c.story_content[phase]
			expect(not chapter.lines.is_empty(), actor + ":" + phase + " has playable rows")
			expect(chapter.portrait == ("h_neutral" if phase in ["dark", "after"] else "ward"), "Correct scene portrait key")
			for row in chapter.lines:
				expect(row.speaker in ["player", "patient", "narrator"] and not row.text.is_empty() and not row.text_en.is_empty(), "Bilingual speaker/line " + actor + ":" + phase)
		var result := Ready.inspect_actor(g, actor, texts, assets)
		report.append(result)
		if actor in profiles:
			expect(result.ready, "Lv5 release readiness " + actor + ": " + str(result.missing))
			var english_patient := preload("res://godot/systems/advanced_presentation.gd").patient({"staff_patient_id": actor, "procedure_id": "surgery_open_whipple"}, g, true)
			var english_portraits: Dictionary = english_patient.visuals.portraits.duplicate(true)
			english_portraits.erase("team_confirmation")
			expect(Ready.validate(texts.actors[actor], english_portraits, assets.get(actor, {})).is_empty(), "English presentation loads all required images: " + actor)
			Setup.fixture(g, actor)
			expect(g.staff_patient_unlocked(actor), "Actual authored Lv5 completion unlocks patient: " + actor)
			expect(StaffEpisode.new(g, actor).eligible(), "Lv5 prerequisites permit advanced episode: " + actor)
		else:
			if not g.staff_record(actor).is_empty():
				g.meet_staff(actor)
				g.relation_for(actor).level = 5
			expect(not g.staff_patient_unlocked(actor) and not c.eligible(), "Preloading / numeric Lv5 cannot unlock unfinished route: " + actor)
	for actor in profiles:
		expect(texts.actors.has(actor), "Every registered patient has a preloaded script: " + actor)
		expect(Ready.validate_dialogue(profiles[actor]).is_empty(), "Complete bilingual patient dialogue: " + actor)
	var broken_profile: Dictionary = profiles.doc_serika.duplicate(true)
	broken_profile.dialogue.en.erase("invitation_lines")
	expect(not Ready.validate_dialogue(broken_profile).is_empty(), "Detect missing English dialogue group")
	broken_profile = profiles.doc_serika.duplicate(true)
	broken_profile.dialogue.en.invitation_lines[0] = ""
	expect(not Ready.validate_dialogue(broken_profile).is_empty(), "Detect empty English patient line")
	broken_profile = profiles.doc_serika.duplicate(true)
	broken_profile.dialogue.en.invitation_lines[0] = broken_profile.dialogue.zh_CN.invitation_lines[0]
	expect(not Ready.validate_dialogue(broken_profile).is_empty(), "Detect Chinese fallback in English patient line")
	broken_profile = profiles.doc_serika.duplicate(true)
	broken_profile.dialogue.en.invitation_lines[0] = str(broken_profile.dialogue.en.invitation_lines[0]).replace("{procedure_name}", "")
	expect(not Ready.validate_dialogue(broken_profile).is_empty(), "Detect missing patient dialogue placeholder")
	broken_profile = profiles.doc_serika.duplicate(true)
	broken_profile.dialogue.zh_CN.invitation_lines.clear()
	broken_profile.dialogue.en.invitation_lines.clear()
	expect(not Ready.validate_dialogue(broken_profile).is_empty(), "Detect absent invitation in both locales")
	# Negative controls: missing chapters, translation and each required image must fail.
	var patient := preload("res://godot/systems/advanced_presentation.gd").patient({"staff_patient_id":"doc_serika", "procedure_id":"surgery_open_whipple"}, g, false)
	var portraits: Dictionary = patient.visuals.portraits.duplicate(true)
	portraits.erase("team_confirmation")
	var valid: Dictionary = texts.actors.doc_serika
	for phase in Ready.PHASES:
		var broken := valid.duplicate(true)
		broken.erase(phase)
		expect(not Ready.validate(broken, portraits, assets.doc_serika).is_empty(), "Detect missing chapter " + phase)
		broken = valid.duplicate(true)
		broken[phase][0].text_en = ""
		expect(not Ready.validate(broken, portraits, assets.doc_serika).is_empty(), "Detect missing English " + phase)
	for key in ["ward/neutral", "h_neutral", "intraoperative/anesthetized"]:
		var broken := portraits.duplicate(true)
		broken.erase(key)
		expect(not Ready.validate(valid, broken, assets.doc_serika).is_empty(), "Detect missing portrait " + key)
	for pose in Ready.POSES:
		var broken: Dictionary = assets.doc_serika.duplicate(true)
		broken.erase(pose)
		expect(not Ready.validate(valid, portraits, broken).is_empty(), "Detect missing pose " + pose)
	var report_file := FileAccess.open("/tmp/hoshimi_staff_patient_lv5_readiness.json", FileAccess.WRITE)
	report_file.store_string(JSON.stringify(report, "\t"))
	print("STAFF PATIENT LV5 READINESS: %s checks; %s failures; %s registered, %s preloaded" % [checks, failures, profiles.size(), texts.actors.size()])
	quit(1 if failures else 0)

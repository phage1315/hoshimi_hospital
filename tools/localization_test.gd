extends SceneTree

const Loader = preload("res://godot/scripts/content_loader.gd")

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
	var chinese = Loader.new()
	expect(chinese.load_all("zh_CN"), "Chinese content failed to load")
	expect(chinese.protagonist.name == "坂口隆司", "Chinese source fallback changed")
	expect(chinese.find_record("surgeries", "surgery_appendix").name == "开腹阑尾切除", "Chinese surgery name changed")

	var english = Loader.new()
	expect(english.load_all("en"), "English localization failed to load")
	expect(english.protagonist.name == "Ryuji Sakaguchi", "Localized protagonist name was not resolved")
	expect(english.dialogue.nodes[0].id == chinese.dialogue.nodes[0].id, "Localization changed a stable dialogue ID")
	expect(english.dialogue.nodes[0].text.begins_with("April sunlight"), "Localized authored dialogue was not resolved")
	expect(english.find_record("surgeries", "surgery_appendix").name == "Open Appendectomy", "Localized surgery name was not resolved")
	expect(english.find_record("staff", "doc_shiori").name == "Shiori Fujisaki", "Localized staff name was not resolved")
	expect(english.find_record("staff", "doc_shiori").specialty == "General Internal Medicine", "Localized staff specialty was not resolved")
	expect(english.find_record("locations", "clinic").description.begins_with("The first patient"), "Localized location description was not resolved")
	expect(english.find_record("case_templates", "template_appendicitis").title == "Acute Appendicitis", "Localized case-pool title was not resolved")
	expect(english.find_record("surgeries", "surgery_appendix").stages[0].title == "Incision and Entry", "Localized surgery-flow stage was not resolved")
	expect(english.find_record("patient_interactions", "contact_default_01").prompt.begins_with("“Doctor"), "Localized awake-surgery interaction was not resolved")
	expect(english.find_record("character_events", "intro_doc_rei").title.begins_with("Meet Kaori"), "Localized day-one character introduction was not resolved")
	expect(english.find_record("character_events", "sayaka_lv1_first_date").title == "So, Does This Count as a Date?", "Localized Sayaka Lv.1 event was not resolved")
	expect(english.find_record("first_surgery_diagnosis_reactions", "diagnosis_generic_real_01").lines[3] == "\u201cYou really are going to operate on me.\u201d", "Localized first-surgery diagnosis reaction was not resolved")
	expect(english.find_record("patients", "patient_ann").outpatient_lines.complaint == "Well, {line}", "Localized patient-owned outpatient voice was not resolved")
	expect(english.text("ui.title.start", "开始游戏") == "Start Game    →", "Localized hard-coded UI string was not resolved")
	expect(english.text("ui.map.title", "医院导览") == "Hospital Directory", "Localized public map UI was not resolved")
	expect(english.text("ui.save.slot", "位置 %02d") % 3 == "Slot 03", "Localized formatted save-slot UI was not resolved")
	expect(english.text("ui.sunday.candidate", "%s　Lv%s　熟悉 %s") % ["Test", 1, 20] == "Test   Lv.1   Familiarity 20", "Localized Sunday UI placeholders were not resolved")
	expect(english.text("ui.clinic.record_title", "病历 / %s") % "Test" == "Medical Record / Test", "Localized clinic UI was not resolved")
	expect(english.text("ui.staff.outfit.scrubs", "刷手服 · 帽子口罩") == "Scrubs · Cap and Mask", "Localized staff variant UI was not resolved")
	expect(english.text("missing.key", "中文回退") == "中文回退", "Unknown key did not use its source fallback")
	expect(english.localizer.text("format.test", "欢迎，{name}", {"name": "坂口"}) == "欢迎，坂口", "Localization replacement tokens failed")
	print("LOCALIZATION: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

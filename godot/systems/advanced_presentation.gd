extends RefCounted
## Existing asset and dialogue references only. No authored text is rewritten.
const ModelPose = preload("res://godot/systems/advanced_staff_patient_assets.gd")
const LEGACY_PATIENTS := ["patient_sora", "patient_emi", "patient_miki"]

static func random_patient_ids(game: RefCounted = null) -> Array:
	# Ordinary patient registry only: excludes authored first cases and staff patients.
	var patients: Array = game.patient_definitions if game != null else []
	if game == null:
		var index: Array = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/index.json"))
		for path in index:
			var bundle: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/patients/" + str(path)))
			patients.append(bundle.patient)
	var ids: Array = []
	for person in patients:
		var id := str(person.get("id", ""))
		if not id.is_empty() and id not in ids: ids.append(id)
	ids.sort()
	return ids
const DEFAULT_TEAM := {"first_assistant":"doc_emiko", "second_assistant":"doc_artoria", "primary_scrub":"nurse_haru", "secondary_scrub":"nurse_yui", "primary_circulating":"nurse_rin", "secondary_circulating":"nurse_ange", "anesthesia":"doc_sakura_anesthesiology"}
const ROLES := ["first_assistant", "second_assistant", "primary_scrub", "secondary_scrub", "primary_circulating", "secondary_circulating", "anesthesia"]
const BASIC_ROLES := {"first_assistant":"assistant_surgeon", "second_assistant":"assistant_surgeon", "primary_scrub":"scrub_nurse", "secondary_scrub":"scrub_nurse", "primary_circulating":"circulating_nurse", "secondary_circulating":"circulating_nurse"}
const GROUPS := {"surgery_open_whipple":"general_abdominal", "surgery_adv_pelvic_sidewall_tumor_vascular_reconstruction":"female_pelvic", "surgery_adv_sleeve_lobectomy":"thoracic", "surgery_adv_complex_abdominal_reconstruction":"general_abdominal", "surgery_adv_open_descending_thoracic_aortic_replacement":"thoracic"}
var definition: Dictionary = {} # Proxy for the existing anesthesia splash renderer.
static var staff_confirmations: Dictionary = {}

static func confirmation(actor: String, category: String, trigger: String, procedure: String, english: bool) -> String:
	if staff_confirmations.is_empty():
		staff_confirmations = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/dialogue/staff_confirmations.json"))
	if procedure not in staff_confirmations.get("procedure_ids", []): return ""
	for row in staff_confirmations.get("lines", []):
		if row.character_id == actor and row.role == category and row.trigger == trigger:
			return str(row.text_en if english else row.text)
	return ""

static func role_category(role: String) -> String:
	if role in ["first_assistant", "second_assistant"]: return "assistant"
	if role in ["primary_scrub", "secondary_scrub"]: return "scrub"
	if role in ["primary_circulating", "secondary_circulating"]: return "circulating"
	return role

static func patient_id(record: Dictionary, game: RefCounted = null) -> String:
	if record.has("staff_patient_id"): return str(record.staff_patient_id)
	var authored := preload("res://godot/systems/advanced_first_story.gd").patient(record, false)
	if not authored.is_empty(): return str(authored.id)
	var pending := pending_patient(record, false)
	if not pending.is_empty(): return str(pending.id)
	if str(record.get("patient_id", "")) in random_patient_ids(game): return str(record.patient_id)
	# Old saves stored placeholders. Retain their original visible identity.
	if bool(record.get("replay", false)): return LEGACY_PATIENTS[posmod(hash(str(record.id)), LEGACY_PATIENTS.size())]
	var index := GROUPS.keys().find(str(record.get("procedure_id", "")))
	return LEGACY_PATIENTS[maxi(0, index)]

static func patient(record: Dictionary, game: RefCounted, english: bool) -> Dictionary:
	if record.has("staff_patient_id"):
		var actor := str(record.staff_patient_id)
		var person: Dictionary = game.staff_record(actor).duplicate(true)
		if english:
			var localized: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/localization/en.json"))
			person.name = localized.strings.get("collections.staff.%s.name" % actor, person.name)
		var result := preload("res://godot/systems/staff_patient_registry.gd").patient_record(person, "en" if english else "zh_CN")
		var h_registry = preload("res://godot/systems/free_h_registry.gd")
		var h_profile: Dictionary = h_registry.read_json(str(h_registry.definition(actor).get("profile", "")))
		result.visuals.portraits["h_neutral"] = str(h_profile.get("assets", {}).get("portrait_expressions", {}).get("neutral", "")).trim_prefix("res://")
		# Sayaka's production H adapter uses a shared expression atlas rather
		# than the legacy placeholder paths in the author's source profile.
		if str(h_registry.definition(actor).get("adapter", "")) == "sayaka_v1":
			result.visuals.portraits["h_neutral"] = preload("res://godot/systems/h_profile_v1_content.gd").EXPRESSION_ATLAS.trim_prefix("res://")
			result.visuals["portrait_regions"] = {"h_neutral": preload("res://godot/systems/h_profile_v1_session.gd").EXPRESSION_ATLAS_CELLS["neutral"]}
		var assets: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/staff_patient/assets.json"))
		var pose := str(ModelPose.procedure_pose(str(record.procedure_id)))
		result.visuals.portraits["team_confirmation"] = assets.get(actor, {}).get(pose, {}).get("path", "")
		return result
	var authored := preload("res://godot/systems/advanced_first_story.gd").patient(record, english)
	if authored.is_empty(): authored = pending_patient(record, english)
	if not authored.is_empty(): return authored
	var result: Dictionary = game.patient_definition(patient_id(record, game)).duplicate(true)
	if bool(record.get("replay", false)):
		var profile := preload("res://godot/systems/advanced_referral_rules.gd").replay_profile(str(record.get("procedure_id", "")))
		for key in ["diagnosis", "diagnosis_en"]:
			if profile.has(key): result[key] = profile[key]
	return result

static func pending_patient(record: Dictionary, english: bool) -> Dictionary:
	if bool(record.get("replay",false)): return {}
	var registry: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://data/advanced_surgery/pending_first_patients.json"))
	var patient: Dictionary = registry.get(str(record.get("procedure_id","")),{}).duplicate(true)
	if english and not patient.is_empty(): patient.name = patient.name_en
	return patient

static func portrait_key(person: Dictionary, role: String) -> String:
	var portraits: Dictionary = person.get("visuals", {}).get("portraits", {})
	var outfit := "scrubs" if role in ["primary_circulating", "secondary_circulating", "anesthesia"] else "sterile"
	# Prefer an available OR standing portrait before enlarging the HUD-only avatar.
	for key in [outfit + "/focused", outfit + "/neutral", "scrubs/focused", "scrubs/neutral", "sterile/focused", "sterile/neutral", "intraoperative_avatar/neutral"]:
		if portraits.has(key): return key
	return ""

static func ward_portrait_key(person: Dictionary) -> String:
	var visuals: Dictionary = person.get("visuals", {})
	var portraits: Dictionary = visuals.get("portraits", {})
	var outfit := str(visuals.get("default_outfit", "white_coat"))
	for key in [outfit + "/serious", outfit + "/neutral", "white_coat/neutral", "uniform/neutral"]:
		if portraits.has(key): return key
	return ""

static func line(game: RefCounted, actor: String, role: String, key: String, procedure: String, english: bool) -> String:
	var person: Dictionary = game.staff_record(actor)
	var groups: Dictionary = person.get("procedure_group_team_dialogue", {})
	var group: Dictionary = groups.get(GROUPS.get(procedure, ""), groups.get("default", {}))
	if key == "timeout":
		# Explicit procedure-group confirmation retains precedence; the new shared
		# author lines fill only the reviewed role gaps, never Day 1 assignments.
		var authored_confirmation := confirmation(actor, role_category(role), key, procedure, english)
		if not authored_confirmation.is_empty():
			return str(group.get("role_confirmation", authored_confirmation))
		# Role confirmation is a different moment from accepting an assignment.
		# Minato's existing role_confirmation says primary surgeon, not assistant.
		# Nakai and Sakura have confirmations for their specific roles only.
		if (role in ["first_assistant", "second_assistant"] and actor != "doc_minato") or (actor == "nurse_rin" and role in ["primary_circulating", "secondary_circulating"]) or (actor == "doc_sakura_anesthesiology" and role == "anesthesia"):
			var confirmation := str(group.get("role_confirmation", person.get("team_dialogue", {}).get("role_confirmation", "")))
			if not confirmation.is_empty(): return confirmation
		if actor in ["patient_chihaya", "guest_mizuho"] and role in ["primary_circulating", "secondary_circulating"]:
			var lines: Array = person.get("authored_dialogue", {}).get("work.OR_02", [])
			if not lines.is_empty(): return str(lines[0])
		return line(game, actor, role, "assignment", procedure, english)
	# These two existing routine lines explicitly address an awake patient's responses.
	if key == "intraoperative" and actor in ["doc_aoi", "nurse_haru"]: return ""
	var authored := str(group.get(key, person.get("team_dialogue", {}).get(key, "")))
	if not authored.is_empty(): return authored
	if key != "assignment": return ""
	var bridge := preload("res://godot/systems/advanced_physiology.gd").new({"id":procedure,"name":""}, game.staff, {})
	bridge.definition["_locale"] = "en" if english else "zh_CN"
	bridge.surgery_team_dialogue_profiles = game.surgery_team_dialogue_profiles
	return bridge.assignment_response(str(BASIC_ROLES.get(role, role)), actor)

static func is_spoken(text: String) -> bool:
	return text.begins_with("「") or text.begins_with("“") or text.begins_with('"')

static func format_story(text: String, procedure_name: String) -> String:
	return text.replace("〈本次术式〉", procedure_name)

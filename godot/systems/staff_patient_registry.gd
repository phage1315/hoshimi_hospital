extends RefCounted
## Staff admissions are separate from the rotating outpatient catalog.
## Authored dialogue is locale-scoped in data/staff_patient_profiles.json:
## reaction_lines: {reaction_id: text}; reaction_variants: {reaction_id: [text]}.
## interaction_overrides: {existing_pool_id: {prompt: text, responses: {existing_action_id: text}}}.
## stage_prompts: {existing_stage_id: text}; team_overrides: {staff_id: {action_id: text}}.
## Team keys also accept existing intraoperative option IDs (with :correction
## for correction responses) and assignment:<role_id> for assignment responses.
## address_context: {surgeon_name: text}; only explicit {surgeon_name} tokens expand.
## invitation_lines: [text]; invitation_by_procedure: {canonical_surgery_id: [text]}.
## ward_visit_opening: [{speaker: narrator|patient|player, text: text}]; optional
## runtime-only entrance, ending at the existing ward choices with no effects.
## reaction_speakers: {reaction_id: patient}; only explicit patient reactions.
## graphic_preop_by_procedure: {agreed_surgery_id: {node_id: {text, speaker}}}.
## agreement_required_interaction_ids lives on the profile, outside localized text.
## No draft dialogue is implicitly imported, and no actions/effects are overridden.
const Loader = preload("res://godot/scripts/content_loader.gd")
const PREOP_ID := "preop_staff_patient"
const PATH := "res://data/staff_patient_profiles.json"
const MISCHIEF_PATH := "res://data/staff_patient_mischief_dialogue.json"

static func profiles() -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return value if value is Dictionary else {}

static func profile(actor_id: String) -> Dictionary:
	return profiles().get(actor_id, {})

static func dialogue(actor_id: String, locale: String) -> Dictionary:
	return profile(actor_id).get("dialogue", {}).get(locale, {})

static func mischief_profiles() -> Dictionary:
	if not FileAccess.file_exists(MISCHIEF_PATH):
		return {}
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(MISCHIEF_PATH))
	return value if value is Dictionary else {}

static func mischief_dialogue(actor_id: String, locale: String) -> Dictionary:
	return mischief_profiles().get(actor_id, {}).get("dialogue", {}).get(locale, {})

static func patient_record(person: Dictionary, locale: String) -> Dictionary:
	if person.is_empty() or profile(str(person.id)).is_empty():
		return {}
	var config := profile(str(person.id))
	var lines := dialogue(str(person.id), locale).duplicate(true)
	var extra_mischief := mischief_dialogue(str(person.id), locale)
	var reaction_variants: Dictionary = lines.get("reaction_variants", {}).duplicate(true)
	for rid in extra_mischief.get("reaction_variants", {}):
		reaction_variants[rid] = extra_mischief["reaction_variants"][rid].duplicate(true)
	var team_overrides: Dictionary = lines.get("team_overrides", {}).duplicate(true)
	for staff_id in extra_mischief.get("team_overrides", {}):
		var merged_staff: Dictionary = team_overrides.get(staff_id, {}).duplicate(true)
		var extra_staff: Dictionary = extra_mischief["team_overrides"][staff_id]
		for action_id in extra_staff:
			merged_staff[action_id] = extra_staff[action_id]
		team_overrides[staff_id] = merged_staff
	if not team_overrides.is_empty():
		lines["team_overrides"] = team_overrides
	var visuals: Dictionary = person.get("visuals", {}).duplicate(true)
	var portraits: Dictionary = visuals.get("portraits", {})
	for alias in config.get("portrait_aliases", {}):
		var source := str(config.portrait_aliases[alias])
		if portraits.has(source):
			portraits[alias] = portraits[source]
	visuals["portraits"] = portraits
	visuals["default_outfit"] = "ward"
	var result := {"id": person.id, "name": person.name, "age": person.age,
		"medical_background": true, "has_prior_surgery": true,
		"visuals": visuals, "personality": config.get("personality", {}),
		"traits": config.get("traits", {}), "reaction_lines": lines.get("reaction_lines", {}).duplicate(true),
		"reaction_variants": reaction_variants, "staff_patient_dialogue": lines}
	# Reuse the same locale-aware personality base as ordinary patients. Only
	# explicitly authored staff reactions override it; never copy another actor.
	var profile_id := str(config.get("dialogue_profile", ""))
	if not profile_id.is_empty():
		var loader := Loader.new()
		if loader.localizer.load_locale(locale):
			var source: Dictionary = loader.read_json("res://data/patients/dialogue_profiles.json")
			var base: Dictionary = source.get("profiles", {}).get(profile_id, {})
			result["dialogue_profile"] = profile_id
			loader.merge_patient_dialogue_profile(result, {profile_id: loader.localizer.localize_tree(base, "patient_dialogue_profiles." + profile_id)}, str(person.id))
	for reserved in config.get("reserved_reaction_ids", []):
		result.reaction_lines.erase(reserved)
	return result

static func preop_definition(person: Dictionary, surgery: Dictionary, locale: String) -> Dictionary:
	if person.is_empty() or surgery.is_empty():
		return {}
	var loader := Loader.new()
	if not loader.localizer.load_locale(locale):
		return {}
	var template: Variant = loader.read_json("res://data/patients/templates/preop.json")
	if not template is Dictionary:
		return {}
	template = loader.localizer.localize_tree(template, "patient_templates.preop")
	var result: Dictionary = loader.replace_patient_tokens(template, {
		"$PATIENT_ID": person.id, "$PATIENT_NAME": person.name,
		"$PREOP_ID": PREOP_ID, "$VISIT_ID": "", "$FALLBACK_SURGERY_ID": surgery.id})
	result["staff_patient_id"] = person.id
	result["agreed_procedure_id"] = surgery.id
	result["agreement_required_interaction_ids"] = profile(str(person.id)).get("agreement_required_interaction_ids", []).duplicate()
	result["_locale"] = locale
	result["title"] = "%s · %s" % [person.name, surgery.name]
	var prompts: Dictionary = dialogue(str(person.id), locale).get("stage_prompts", {})
	for stage in result.stages:
		if prompts.has(stage.id):
			stage.prompt = prompts[stage.id]
	# Optional authored ward entrance, using ordinary zero-effect story stages.
	# These nodes exist only in the runtime definition; saves retain admission facts.
	var opening: Array = dialogue(str(person.id), locale).get("ward_visit_opening", [])
	if not opening.is_empty():
		var ward: Dictionary = {}
		for stage in result.stages:
			if stage.id == "ward_visit":
				ward = stage
		if not ward.is_empty() and str(result.start) == "ward_visit":
			ward.prompt = opening[-1].text
			ward.speaker = opening[-1].speaker
			for i in range(opening.size() - 1):
				var entrance := ward.duplicate(true)
				entrance.id = "ward_opening_%d" % i
				entrance.prompt = opening[i].text
				entrance.speaker = opening[i].speaker
				entrance["ward_opening"] = true
				var next_id := "ward_opening_%d" % (i + 1) if i < opening.size() - 2 else "ward_visit"
				entrance.actions = [{"id": "continue_ward_opening_%d" % i,
					"label": "Continue →" if locale == "en" else "继续 →", "response": "",
					"response_speaker": "narrator", "next": next_id, "requires": [],
					"flags": [], "calm": 0, "minutes": 0, "requires_team": false,
					"execute_preparation": false, "response_role": "", "response_by_staff": {}}]
				result.stages.append(entrance)
			result.start = "ward_opening_0" if opening.size() > 1 else "ward_visit"
	return result

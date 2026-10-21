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
## reaction_speakers: {reaction_id: patient}; only explicit patient reactions.
## graphic_preop_by_procedure: {agreed_surgery_id: {node_id: {text, speaker}}}.
## agreement_required_interaction_ids lives on the profile, outside localized text.
## No draft dialogue is implicitly imported, and no actions/effects are overridden.
const Loader = preload("res://godot/scripts/content_loader.gd")
const PREOP_ID := "preop_staff_patient"
const PATH := "res://data/staff_patient_profiles.json"

static func profiles() -> Dictionary:
	var value: Variant = JSON.parse_string(FileAccess.get_file_as_string(PATH))
	return value if value is Dictionary else {}

static func profile(actor_id: String) -> Dictionary:
	return profiles().get(actor_id, {})

static func dialogue(actor_id: String, locale: String) -> Dictionary:
	return profile(actor_id).get("dialogue", {}).get(locale, {})

static func patient_record(person: Dictionary, locale: String) -> Dictionary:
	if person.is_empty() or profile(str(person.id)).is_empty():
		return {}
	var config := profile(str(person.id))
	var lines := dialogue(str(person.id), locale)
	var visuals: Dictionary = person.get("visuals", {}).duplicate(true)
	var portraits: Dictionary = visuals.get("portraits", {})
	for alias in config.get("portrait_aliases", {}):
		var source := str(config.portrait_aliases[alias])
		if portraits.has(source):
			portraits[alias] = portraits[source]
	visuals["portraits"] = portraits
	visuals["default_outfit"] = "ward"
	return {"id": person.id, "name": person.name, "age": person.age,
		"medical_background": true, "has_prior_surgery": true,
		"visuals": visuals, "personality": config.get("personality", {}),
		"traits": config.get("traits", {}), "reaction_lines": lines.get("reaction_lines", {}),
		"reaction_variants": lines.get("reaction_variants", {}), "staff_patient_dialogue": lines}

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
	return result

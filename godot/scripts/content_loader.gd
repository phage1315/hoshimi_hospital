extends RefCounted
## Read-only authored content. UI never writes back to these dictionaries.
var collections: Dictionary = {}
var dialogue: Dictionary = {}
var protagonist: Dictionary = {}
var errors: Array[String] = []

func read_json(path: String) -> Variant:
	if not FileAccess.file_exists(path):
		errors.append("文件不存在：" + path)
		return null
	var parser := JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		errors.append("JSON 错误：%s / 行 %s" % [path, parser.get_error_line()])
		return null
	return parser.data

func replace_patient_tokens(value: Variant, tokens: Dictionary) -> Variant:
	if value is Dictionary:
		var result := {}
		for key in value:
			result[key] = replace_patient_tokens(value[key], tokens)
		return result
	if value is Array:
		var result := []
		for entry in value:
			result.append(replace_patient_tokens(entry, tokens))
		return result
	if value is String:
		var result: String = value
		for token in tokens:
			result = result.replace(str(token), str(tokens[token]))
		return result
	return value

func apply_patient_bundle_overrides(encounter: Dictionary, preop: Dictionary, bundle: Dictionary) -> void:
	var encounter_data: Dictionary = bundle.get("encounter", {})
	encounter["title"] = str(encounter_data.get("title", encounter.get("title", "")))
	var full_undress: Dictionary = encounter_data.get("full_undress", {})
	for stage in encounter.get("stages", []):
		if str(stage.get("id", "")) != "exam_undress_decision":
			continue
		stage["prompt"] = str(full_undress.get("prompt", stage.get("prompt", "")))
		var responses: Dictionary = full_undress.get("responses", {})
		var visual_pool_id: String = str(full_undress.get("visual_pool_id", ""))
		for action in stage.get("actions", []):
			var action_id: String = str(action.get("id", ""))
			if responses.has(action_id):
				action["response"] = str(responses[action_id])
			if action_id in ["authoritative_full_undress", "gentle_full_undress", "threaten_full_undress"]:
				if visual_pool_id.is_empty():
					action.erase("visual_pool_id")
				else:
					action["visual_pool_id"] = visual_pool_id
	var preop_data: Dictionary = bundle.get("preop", {})
	preop["title"] = str(preop_data.get("title", preop.get("title", "")))
	preop["initial_anxiety"] = int(preop_data.get("initial_anxiety", preop.get("initial_anxiety", 0)))
	preop["initial_interaction"] = preop_data.get("initial_interaction", preop.get("initial_interaction", {})).duplicate(true)
	var preop_prompts: Dictionary = preop_data.get("stage_prompts", {})
	var incision_responses: Dictionary = preop_data.get("incision_responses", {})
	for stage in preop.get("stages", []):
		var stage_id: String = str(stage.get("id", ""))
		if preop_prompts.has(stage_id):
			stage["prompt"] = str(preop_prompts[stage_id])
		if stage_id == "incision_ready":
			for action in stage.get("actions", []):
				var action_id: String = str(action.get("id", ""))
				if incision_responses.has(action_id):
					action["response"] = str(incision_responses[action_id])

func load_patient_bundles(config: Dictionary) -> void:
	var index: Variant = read_json("res://data/" + str(config.get("index", "")))
	var encounter_template: Variant = read_json("res://data/" + str(config.get("encounter_template", "")))
	var preop_template: Variant = read_json("res://data/" + str(config.get("preop_template", "")))
	if not index is Array or not encounter_template is Dictionary or not preop_template is Dictionary:
		errors.append("患者数据包索引或共用模板无效")
		return
	collections["patients"] = []
	collections["encounters"] = []
	collections["preops"] = []
	if not collections.has("examination_cg_pools"):
		collections["examination_cg_pools"] = []
	if not collections.has("ward_preparation_cg_pools"):
		collections["ward_preparation_cg_pools"] = []
	var patient_ids := {}
	var generated_ids := {}
	for bundle_path in index:
		var bundle: Variant = read_json("res://data/patients/" + str(bundle_path))
		if not bundle is Dictionary or int(bundle.get("schema_version", 0)) != 1 or not bundle.get("patient") is Dictionary:
			errors.append("患者数据包无效：" + str(bundle_path))
			continue
		var patient: Dictionary = bundle.patient.duplicate(true)
		var patient_id: String = str(patient.get("id", ""))
		if patient_id.is_empty() or patient_ids.has(patient_id):
			errors.append("患者 ID 缺失或重复：" + patient_id)
			continue
		patient_ids[patient_id] = true
		var short_id: String = patient_id.trim_prefix("patient_")
		var fallback: Dictionary = bundle.get("fallback", {})
		var tokens := {
			"$PATIENT_ID": patient_id,
			"$PATIENT_NAME": str(patient.get("name", "")),
			"$VISIT_ID": "visit_" + short_id,
			"$PREOP_ID": "preop_" + short_id,
			"$FALLBACK_CASE_ID": str(fallback.get("case_id", patient.get("case_id", ""))),
			"$FALLBACK_SURGERY_ID": str(fallback.get("surgery_id", "")),
		}
		var encounter: Dictionary = replace_patient_tokens(encounter_template, tokens)
		var preop: Dictionary = replace_patient_tokens(preop_template, tokens)
		apply_patient_bundle_overrides(encounter, preop, bundle)
		for generated in [encounter, preop]:
			var generated_id: String = str(generated.get("id", ""))
			if generated_id.is_empty() or generated_ids.has(generated_id):
				errors.append("生成的患者流程 ID 缺失或重复：" + generated_id)
			else:
				generated_ids[generated_id] = true
		collections.patients.append(patient)
		collections.encounters.append(encounter)
		collections.preops.append(preop)
		var exclusive_pools: Dictionary = bundle.get("exclusive_cg_pools", {})
		for pool in exclusive_pools.get("examination", []):
			var pool_id: String = str(pool.get("id", ""))
			if find_record("examination_cg_pools", pool_id).is_empty():
				collections.examination_cg_pools.append(pool.duplicate(true))
			else:
				errors.append("患者专属检查 CG 池 ID 重复：" + pool_id)
		for pool in exclusive_pools.get("ward_preparation", []):
			var pool_id: String = str(pool.get("id", ""))
			if find_record("ward_preparation_cg_pools", pool_id).is_empty():
				collections.ward_preparation_cg_pools.append(pool.duplicate(true))
			else:
				errors.append("患者专属术前 CG 池 ID 重复：" + pool_id)

func load_all() -> bool:
	collections.clear()
	protagonist.clear()
	errors.clear()
	var manifest: Variant = read_json("res://data/manifest.json")
	if not manifest is Dictionary or manifest.get("schema_version") != 1 or not manifest.get("collections") is Dictionary:
		errors.append("内容清单无效或版本不受支持")
		return false
	var protagonist_record: Variant = read_json("res://data/" + str(manifest.get("protagonist", "")))
	if not protagonist_record is Dictionary or str(protagonist_record.get("id", "")) != "player" or str(protagonist_record.get("name", "")).is_empty():
		errors.append("主角资料无效")
	else:
		protagonist = protagonist_record
	for key in manifest.collections:
		var rows: Variant = read_json("res://data/" + str(manifest.collections[key]))
		if not rows is Array:
			errors.append("集合必须是数组：" + str(key))
			continue
		collections[key] = rows
		var ids := {}
		for row in rows:
			if not row is Dictionary:
				errors.append("集合元素必须是对象：" + str(key))
				continue
			if key == "relationships":
				continue
			var id: String = str(row.get("id", ""))
			if id.is_empty() or ids.has(id):
				errors.append("ID 缺失或重复：" + str(key) + "/" + id)
			ids[id] = true
	var patient_bundle_config: Variant = manifest.get("patient_bundles", {})
	if not patient_bundle_config is Dictionary:
		errors.append("患者数据包配置无效")
	else:
		load_patient_bundles(patient_bundle_config)
	var story: Variant = read_json("res://data/" + str(manifest.get("dialogue", "")))
	if not story is Dictionary or not story.get("nodes") is Array:
		errors.append("对话格式无效")
	else:
		dialogue = story
	return errors.is_empty()

func find_record(collection: String, id: String) -> Dictionary:
	for record in collections.get(collection, []):
		if record.get("id") == id:
			return record
	return {}

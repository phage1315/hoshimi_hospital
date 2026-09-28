extends RefCounted
## Preoperative narrative state. Authored data owns dialogue, tasks and transitions.
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")
const LOWER_ABDOMINAL_PREP_SURGERIES := [
	"surgery_appendix",
	"surgery_exploratory_laparotomy",
	"surgery_open_cholecystectomy",
	"surgery_open_inguinal_hernia",
	"surgery_open_ventral_hernia",
	"surgery_open_distal_gastrectomy",
	"surgery_open_total_gastrectomy",
	"surgery_open_right_hemicolectomy",
	"surgery_open_sigmoid_colectomy",
	"surgery_open_abdominoperineal_resection",
	"surgery_open_whipple",
	"surgery_open_major_liver_resection",
	"surgery_open_splenectomy",
	"surgery_open_ovarian_cystectomy",
	"surgery_open_abdominal_myomectomy",
	"surgery_hysterectomy",
	"surgery_open_radical_cystectomy",
	"surgery_open_nephrectomy",
	"surgery_open_abdominal_aortic_aneurysm",
]
var definition: Dictionary
var roster: Dictionary = {}
var known_staff_ids: Array[String] = []
var restrict_to_known_staff := false
var stages: Dictionary = {}
var surgeries: Dictionary = {}
var surgery_team_dialogue_profiles: Array = []
var patient_interactions: Array = []
var stage_id: String
var events: Array = []
var team: Dictionary = {}
var selected_preparations: Array[String] = []
var flags: Array[String] = []
var done: Array[String] = []
var minutes := 0
var anxiety := 2
var fear := 35
var pain := 0
var dignity := 100
var cooperation_base := 70
var anesthesia := "未选择"
var procedure_id := ""
var procedure_name := ""
var procedure_minutes := 0
var surgery_success := false
var procedure_mismatch := false
var procedure_step_index := 0
var procedure_step_history: Array[Dictionary] = []
var procedure_corrections := 0
var awaiting_flow_acknowledgement := false
var pending_flow_stage_id := ""
var pending_flow_retry := false
var awaiting_patient_choice := false
var awaiting_patient_acknowledgement := false
var active_patient_interaction: Dictionary = {}
var patient_interaction_history: Array[String] = []
var operative_background_id := ""
var patient_name := "患者"
var patient_personality: Dictionary = {}
var patient_traits: Dictionary = {}
var patient_reactions: Dictionary = {}
var patient_reaction_variants: Dictionary = {}
var feedback := ""
var feedback_speaker := "narrator"
var last_error := ""
var last_staff_id := ""
var last_staff_role := ""
var player_effects := {"skill": 0, "ethics": 0, "charisma": 0, "intimidation": 0, "reputation": 0}
var player_effect_history: Array[Dictionary] = []

func _init(data: Dictionary, staff: Array, surgery_data: Array = [], patient_data: Array = [], known_staff: Array[String] = [], restrict_known: bool = false, surgery_team_dialogue_data: Array = [], patient_interaction_data: Array = []) -> void:
	definition = data
	surgery_team_dialogue_profiles = surgery_team_dialogue_data
	patient_interactions = patient_interaction_data
	known_staff_ids = known_staff.duplicate()
	restrict_to_known_staff = restrict_known
	for person in staff:
		roster[person.id] = person
	for stage in data.stages:
		stages[stage.id] = stage
	for surgery in surgery_data:
		surgeries[surgery.id] = surgery
	for patient in patient_data:
		if patient.id == data.patient_id:
			patient_name = patient.name
			patient_personality = patient.get("personality", {}).duplicate(true)
			patient_traits = patient.get("traits", {}).duplicate(true)
			patient_reactions = patient.get("reaction_lines", {}).duplicate(true)
			patient_reaction_variants = patient.get("reaction_variants", {}).duplicate(true)
	for stage in ward_preparation_stages():
		stages[stage.id] = stage
	for stage in operative_preparation_stages():
		stages[stage.id] = stage
	stage_id = data.start
	anxiety = int(data.initial_anxiety)
	var interaction: Dictionary = data.get("initial_interaction", {})
	fear = int(interaction.get("fear", 35))
	pain = int(interaction.get("pain", 0))
	dignity = int(interaction.get("dignity", 100))
	cooperation_base = int(interaction.get("cooperation", 70))

func set_known_staff(ids: Array[String], restrict_known: bool = true) -> void:
	known_staff_ids = ids.duplicate()
	restrict_to_known_staff = restrict_known

func current() -> Dictionary:
	return stages[stage_id]

func surgery_in_progress() -> bool:
	return flags.has("surgery_started") and not surgery_success

func operative_preparation_stages() -> Array:
	return [
		{
			"id": "operative_positioning", "title": "体位摆放与固定", "scene": "operating_room", "kind": "interaction",
			"prompt": "团队依据术式调整仰卧体位，在肩、肘、髋与足跟下加软垫保护受压点；双臂与腿部被安置到预定角度，再用安全固定带限制意外移动。",
			"speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "operative_positioning", "label": "确认受压点保护，完成体位固定",
				"response": "团队托住肩、髋与四肢完成调整，软垫和安全固定带逐一就位。患者在全身麻醉下没有意识反应。",
				"next": "operative_positioning_response", "requires": ["anesthesia_chosen"], "flags": ["operative_positioned"],
				"calm": 0, "minutes": 3, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "operative_positioning_response", "title": "固定后的回应", "scene": "operating_room", "kind": "interaction",
			"prompt": "体位与固定已经确认。", "speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "ack_positioning", "label": "继续：留置导尿", "response": "", "next": "urinary_catheterization",
				"requires": ["operative_positioned"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "urinary_catheterization", "title": "留置导尿", "scene": "operating_room", "kind": "interaction",
			"prompt": "巡回护士核对导尿用品，在保护隐私的同时显露必要范围，以无菌方式清洁并置入导尿管，供长时间手术监测尿量与膀胱引流。",
			"speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "urinary_catheterization", "label": "确认无菌操作，完成留置导尿",
				"response": "巡回护士完成无菌清洁与置管，导尿管固定妥当。患者在全身麻醉下没有意识反应。",
				"next": "urinary_catheterization_response", "requires": ["operative_positioned"], "flags": ["urinary_catheterized"],
				"calm": 0, "minutes": 4, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "urinary_catheterization_response", "title": "导尿后的回应", "scene": "operating_room", "kind": "interaction",
			"prompt": "留置导尿已经完成。", "speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "ack_catheterization", "label": "继续：术野消毒", "response": "", "next": "skin_disinfection",
				"requires": ["urinary_catheterized"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "skin_disinfection", "title": "术野消毒", "scene": "operating_room", "kind": "interaction",
			"prompt": "护士再次核对切入部位，从预定切口中心向外分区涂布消毒液；冰凉液体在皮肤上铺开，待覆盖范围完整后自然干燥。",
			"speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "skin_disinfection", "label": "由中心向外完成消毒并等待干燥",
				"response": "消毒液均匀覆盖预定术野，在灯光下留下短暂的湿润光泽。患者在全身麻醉下没有意识反应。",
				"next": "skin_disinfection_response", "requires": ["urinary_catheterized"], "flags": ["skin_disinfected"],
				"calm": 0, "minutes": 3, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "skin_disinfection_response", "title": "消毒后的回应", "scene": "operating_room", "kind": "interaction",
			"prompt": "术野消毒已经完成并充分干燥。", "speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "ack_disinfection", "label": "继续：复核切口划线", "response": "", "next": "incision_marking",
				"requires": ["skin_disinfected"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "incision_marking", "title": "切口划线", "scene": "operating_room", "kind": "interaction",
			"prompt": "你依据术前已经核对的定位和解剖标志，用无菌皮肤标记笔复核切口走向；笔尖在消毒后的皮肤上留下清晰而克制的线条。",
			"speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "incision_marking", "label": "核对解剖标志，完成切口划线",
				"response": "切口线与术前计划一致，团队完成最后一次位置核对。患者在全身麻醉下没有意识反应。",
				"next": "incision_marking_response", "requires": ["skin_disinfected"], "flags": ["incision_marked"],
				"calm": 0, "minutes": 2, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "incision_marking_response", "title": "划线后的回应", "scene": "operating_room", "kind": "interaction",
			"prompt": "切口范围已经复核，接下来可以正式开始手术。", "speaker": "narrator", "background_id": "operating_room", "actions": [
				{"id": "ack_marking_general", "label": "完成准备，进入开始手术", "response": "", "next": "surgery_start_general", "requires": ["incision_marked"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}, "show_if_flags": ["general_anesthesia"]},
				{"id": "ack_marking_epidural", "label": "完成准备，进入开始手术", "response": "", "next": "surgery_start_epidural", "requires": ["incision_marked"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}, "show_if_flags": ["epidural_anesthesia"]},
				{"id": "ack_marking_local", "label": "完成准备，进入开始手术", "response": "", "next": "surgery_start_local", "requires": ["incision_marked"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}, "show_if_flags": ["local_anesthesia"]},
				{"id": "ack_marking_none", "label": "完成准备，进入开始手术", "response": "", "next": "surgery_start_none_confirmed", "requires": ["incision_marked"], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}, "show_if_flags": ["no_anesthesia_confirmed"]}
			]
		},
		{
			"id": "surgery_start_none_confirmed", "title": "开始手术", "scene": "operating_room", "kind": "interaction",
			"prompt": "四项术前准备已经完成。患者仍在清醒状态下明显抗拒，团队等待你的最终命令。",
			"speaker": "narrator", "background_id": "operating_room", "actions": [{
				"id": "start_none_surgery", "label": "坚持继续，命令：“开始手术。手术刀。”",
				"response": "你再次确认决定，随即向团队下令：「开始手术。手术刀。」",
				"next": "instrument_handoff", "requires": ["no_anesthesia_confirmed", "incision_marked"], "flags": ["surgery_started"],
				"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "player", "effects": {}
			}]
		}
	]

func ward_preparation_stages() -> Array:
	var lower_prep_required := lower_abdominal_preparation_required()
	var enema_prompt := "本次属于开腹或盆腔手术，准备清单要求灌肠。执行时，你会让患者侧卧屈膝，核对液体温度，润滑管端后缓慢置入并分次注入。" if lower_prep_required else "本次手术不涉及腹部或盆腔，准备清单没有要求灌肠。用品仍在推车上；若坚持执行，操作仍包括侧卧置管、分次注入与等待排空。"
	var skin_prep_prompt := "本次属于开腹或盆腔手术，准备清单要求下腹及会阴备皮。执行时，你会让患者仰卧并显露下腹、腹股沟和会阴，用电动备皮器逐区剪短毛发。" if lower_prep_required else "本次手术不涉及腹部或盆腔，准备清单没有要求下腹及会阴备皮。若坚持执行，患者仍需仰卧显露下腹、腹股沟和会阴，由你用电动备皮器逐区处理。"
	var enema_actions: Array = [{
		"id": "ward_enema", "label": "按清单亲手完成灌肠",
		"response": "「等、等一下……肚子已经开始胀了。还要忍多久？」",
		"next": "ward_enema_response", "requires": ["manual_ward_preparation"], "flags": ["ward_enema_complete"],
		"calm": 0, "minutes": 8, "requires_team": false, "execute_preparation": false, "response_speaker": "patient",
		"effects": {"fear": 5, "pain": 3, "dignity": -7, "cooperation": 0}
	}] if lower_prep_required else [{
		"id": "skip_ward_enema", "label": "按清单跳过灌肠",
		"response": "本次术式不要求灌肠，护士在清单上标记为不适用。",
		"next": "ward_enema_response", "requires": ["manual_ward_preparation"], "flags": ["ward_enema_complete", "ward_enema_skipped"],
		"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
	}]
	if lower_prep_required:
		enema_actions.append({
			"id": "skip_required_ward_enema", "label": "跳过灌肠",
			"response": "「这项灌肠在开腹或盆腔手术的准备清单里。跳过会增加术中污染和术后感染风险，请你再次确认。」",
			"next": "ward_enema_response", "requires": ["manual_ward_preparation"], "flags": ["ward_enema_complete", "ward_enema_skipped", "required_enema_omitted"],
			"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "staff",
			"response_role": "ward_nurse", "response_by_staff": {
				"nurse_haru": "「等等，这项灌肠在准备清单里。跳过会增加污染和感染风险……真的要省略吗？」",
				"nurse_rin": "「我反对跳过。清单要求完成灌肠，省略会增加污染与术后感染风险。」",
				"nurse_yui": "「医生，这项不能随便省呀。跳过灌肠会增加污染和感染风险，请再确认一次。」"
			}, "effects": {"fear": 4, "pain": 0, "dignity": 0, "cooperation": -2}
		})
	else:
		enema_actions.append({
			"id": "ward_enema_unnecessary", "label": "仍然执行灌肠",
			"response": "「这次不是腹部手术，为什么还要灌肠……？」",
			"next": "ward_enema_response", "requires": ["manual_ward_preparation"], "flags": ["ward_enema_complete", "unnecessary_enema_performed"],
			"calm": 0, "minutes": 8, "requires_team": false, "execute_preparation": false, "response_speaker": "patient",
			"effects": {"fear": 8, "pain": 3, "dignity": -10, "cooperation": -4}
		})
	var skin_prep_actions: Array = [{
		"id": "ward_skin_prep", "label": "完成下腹及会阴备皮",
		"response": "「连这里也要备皮吗……我知道了，请继续。」",
		"next": "ward_skin_prep_response", "requires": ["ward_enema_complete"], "flags": ["ward_skin_prep_complete"],
		"calm": 0, "minutes": 5, "requires_team": false, "execute_preparation": false, "response_speaker": "patient",
		"effects": {"fear": 3, "pain": 1, "dignity": -8, "cooperation": 0}
	}] if lower_prep_required else [{
		"id": "skip_ward_skin_prep", "label": "按清单跳过下腹及会阴备皮",
		"response": "本次术式不要求下腹及会阴备皮，护士在清单上标记为不适用。",
		"next": "ward_skin_prep_response", "requires": ["ward_enema_complete"], "flags": ["ward_skin_prep_complete", "ward_skin_prep_skipped"],
		"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
	}]
	if lower_prep_required:
		skin_prep_actions.append({
			"id": "skip_required_ward_skin_prep", "label": "跳过下腹及会阴备皮",
			"response": "「下腹及会阴备皮属于这次术野准备。跳过会影响后续消毒和铺单，我建议按清单完成。」",
			"next": "ward_skin_prep_response", "requires": ["ward_enema_complete"], "flags": ["ward_skin_prep_complete", "ward_skin_prep_skipped", "required_skin_prep_omitted"],
			"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false, "response_speaker": "staff",
			"response_role": "ward_nurse", "response_by_staff": {
				"nurse_haru": "「这次要准备下腹和会阴术野。跳过会影响后面的消毒与铺单……还是按清单做吧？」",
				"nurse_rin": "「下腹及会阴备皮属于本次术野准备。我不建议跳过。」",
				"nurse_yui": "「医生，这次真的需要备皮。省掉以后消毒和铺单都会受影响呀。」"
			}, "effects": {"fear": 3, "pain": 0, "dignity": 0, "cooperation": -2}
		})
	else:
		skin_prep_actions.append({
			"id": "ward_skin_prep_unnecessary", "label": "仍然进行下腹及会阴备皮",
			"response": "「明明不是腹部手术，为什么要把下面也处理掉……？」",
			"next": "ward_skin_prep_response", "requires": ["ward_enema_complete"], "flags": ["ward_skin_prep_complete", "unnecessary_skin_prep_performed"],
			"calm": 0, "minutes": 5, "requires_team": false, "execute_preparation": false, "response_speaker": "patient",
			"effects": {"fear": 9, "pain": 1, "dignity": -14, "cooperation": -6}
		})
	return [
		{
			"id": "ward_enema", "title": "病房准备 · 灌肠", "scene": "ward", "kind": "story",
			"prompt": enema_prompt,
			"speaker": "narrator", "background_id": "ward", "actions": enema_actions
		},
		{
			"id": "ward_enema_response", "title": "灌肠后的回应", "scene": "ward", "kind": "story",
			"prompt": "灌肠项目已经处理。护士收走或撤下用物，按刚才的选择在准备记录单上填写结果。",
			"speaker": "narrator", "background_id": "ward", "actions": [{
				"id": "ack_ward_enema", "label": "继续：备皮", "response": "灌肠记录已经核对。",
				"next": "ward_skin_prep", "requires": ["ward_enema_complete"], "flags": [], "calm": 0, "minutes": 0,
				"requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "ward_skin_prep", "title": "病房准备 · 备皮", "scene": "ward", "kind": "story",
			"prompt": skin_prep_prompt,
			"speaker": "narrator", "background_id": "ward", "actions": skin_prep_actions
		},
		{
			"id": "ward_skin_prep_response", "title": "备皮后的回应", "scene": "ward", "kind": "story",
			"prompt": "下腹及会阴备皮项目已经处理。护士按刚才的选择填写结果，再把手术帽放到床边。",
			"speaker": "narrator", "background_id": "ward", "actions": [{
				"id": "ack_ward_skin_prep", "label": "继续：戴手术帽", "response": "术野备皮已经完成。",
				"next": "ward_surgical_cap", "requires": ["ward_skin_prep_complete"], "flags": [], "calm": 0, "minutes": 0,
				"requires_team": false, "execute_preparation": false, "response_speaker": "narrator", "effects": {}
			}]
		},
		{
			"id": "ward_surgical_cap", "title": "病房准备 · 戴手术帽", "scene": "ward", "kind": "story",
			"prompt": "你接过护士递来的手术帽，站到患者身后，将她的头发从颈侧和耳边拢起，一缕一缕收进帽内；确认发尾全部包住后，你沿帽缘按了一圈。",
			"speaker": "narrator", "background_id": "ward", "actions": [{
				"id": "ward_surgical_cap", "label": "替她拢好头发，戴上手术帽",
				"response": "「这样就要去手术室了吗……看起来真的像个要被推去开刀的病人了。」",
				"next": "ward_surgical_cap_response", "requires": ["ward_skin_prep_complete"], "flags": ["ward_cap_fitted"],
				"calm": 0, "minutes": 3, "requires_team": false, "execute_preparation": false, "response_speaker": "patient",
				"effects": {"fear": 2, "pain": 0, "dignity": -2, "cooperation": 1}
			}]
		},
		{
			"id": "ward_surgical_cap_response", "title": "病房准备完成", "scene": "ward", "kind": "story",
			"prompt": "病房准备已经完成。护士用清洁床单遮盖患者，再扶她躺上已经推到床边的担架车；随后拉好护栏、整理输液管路，等着接手送往手术室。",
			"speaker": "narrator", "background_id": "ward", "actions": [{
				"id": "complete_manual_ward_preparation", "label": "把担架车交给病房护士",
				"response": "「接下来交给我，我会推她去手术室。」",
				"next": "prepared", "requires": ["ward_cap_fitted"], "flags": ["patient_prepared", "manual_ward_preparation_complete"],
				"calm": 0, "minutes": 1, "requires_team": true, "execute_preparation": true, "response_speaker": "staff",
				"response_role": "ward_nurse", "response_by_staff": {
					"nurse_haru": "「好，接下来交给我。我会慢慢推她去手术室。」",
					"nurse_rin": "「准备项目都核对完了。接下来由我把她送到手术室。」",
					"nurse_yui": "「护栏和管路都好了。医生放心，我现在推她去手术室。」"
				}, "effects": {}
			}]
		}
	]

func lower_abdominal_preparation_required() -> bool:
	return LOWER_ABDOMINAL_PREP_SURGERIES.has(str(definition.surgery_id))

func role_definition(id: String) -> Dictionary:
	if definition.ward_role.id == id:
		return definition.ward_role
	for role in definition.roles:
		if role.id == id:
			return role
	return {}

func qualified(id: String, role: Dictionary) -> bool:
	if role.is_empty() or not roster.has(id):
		return false
	if restrict_to_known_staff and id not in known_staff_ids:
		return false
	var person: Dictionary = roster[id]
	return str(person.get("team_category", person.profession)) == str(role.profession)

func candidates(role_id: String) -> Array:
	var result: Array = []
	var role := role_definition(role_id)
	for id in roster:
		if qualified(id, role):
			result.append(roster[id])
	return result

func surgery_options() -> Array:
	var result: Array = surgeries.values()
	result.sort_custom(func(a: Dictionary, b: Dictionary): return int(a.duration_minutes) < int(b.duration_minutes))
	return result

func surgery_flow_steps() -> Array:
	if procedure_id.is_empty() or not surgeries.has(procedure_id):
		return []
	return surgeries[procedure_id].get("stages", [])

func surgery_flow_step() -> Dictionary:
	var flow: Array = surgery_flow_steps()
	if procedure_step_index < 0 or procedure_step_index >= flow.size():
		return {}
	return flow[procedure_step_index]

func current_surgery() -> Dictionary:
	return surgeries.get(procedure_id, {})

func dominant_patient_state() -> String:
	var candidates := [
		{"id": "pain", "severity": float(pain) / 100.0, "eligible": pain >= 60, "tie": 0},
		{"id": "fear", "severity": float(fear) / 100.0, "eligible": fear >= 70, "tie": 1},
		{"id": "dignity", "severity": float(100 - dignity) / 100.0, "eligible": dignity <= 40, "tie": 2},
		{"id": "cooperation", "severity": float(100 - cooperation_value()) / 100.0, "eligible": cooperation_value() <= 40, "tie": 3},
	]
	var selected: Dictionary = {}
	for candidate in candidates:
		if not candidate.eligible:
			continue
		if selected.is_empty() or float(candidate.severity) > float(selected.severity) or (is_equal_approx(float(candidate.severity), float(selected.severity)) and int(candidate.tie) < int(selected.tie)):
			selected = candidate
	return "default" if selected.is_empty() else str(selected.id)

func arrays_intersect(left: Array, right: Array) -> bool:
	for value in left:
		if right.has(value):
			return true
	return false

func patient_interaction_scope(interaction: Dictionary, surgery_id: String, procedure_group: String) -> int:
	var surgery_ids: Array = interaction.get("surgery_ids", [])
	var procedure_groups: Array = interaction.get("procedure_groups", [])
	if not surgery_ids.is_empty():
		return 2 if surgery_ids.has(surgery_id) else -1
	if not procedure_groups.is_empty():
		return 1 if procedure_groups.has(procedure_group) else -1
	return 0

func patient_interaction_specificity(interaction: Dictionary, theme: String, cues: Array, state: String) -> int:
	if str(interaction.get("theme", "")) != theme:
		return -1
	var states: Array = interaction.get("states", [])
	var interaction_cues: Array = interaction.get("cues", [])
	var state_match: bool = state != "default" and states.has(state)
	if not states.is_empty() and not state_match:
		return -1
	var cue_match: bool = arrays_intersect(interaction_cues, cues)
	if not interaction_cues.is_empty() and not cue_match:
		return -1
	if state_match and cue_match:
		return 3
	if state_match and interaction_cues.is_empty():
		return 2
	if states.is_empty() and cue_match:
		return 1
	return 0

func match_patient_interaction(theme: String, cues: Array, state: String) -> Dictionary:
	var surgery: Dictionary = current_surgery()
	if surgery.is_empty():
		return {}
	var surgery_id: String = str(surgery.id)
	var procedure_group: String = str(surgery.get("procedure_group", ""))
	for scope in [2, 1, 0]:
		for specificity in [3, 2, 1, 0]:
			var matches: Array[Dictionary] = []
			for interaction in patient_interactions:
				if patient_interaction_scope(interaction, surgery_id, procedure_group) != scope:
					continue
				if patient_interaction_specificity(interaction, theme, cues, state) != specificity:
					continue
				if bool(interaction.get("once_per_surgery", false)) and patient_interaction_history.has(str(interaction.id)):
					continue
				matches.append(interaction)
			if matches.is_empty():
				continue
			for interaction in matches:
				if not patient_interaction_history.has(str(interaction.id)):
					return interaction
			return matches[0]
	return {}

func resolve_patient_event_for_stage() -> bool:
	active_patient_interaction.clear()
	awaiting_patient_choice = false
	if flags.has("anesthetized"):
		return false
	var flow_step: Dictionary = surgery_flow_step()
	if flow_step.is_empty():
		return false
	var theme: String = str(flow_step.get("awake_interlude", ""))
	if theme.is_empty():
		return false
	var interaction := match_patient_interaction(theme, flow_step.get("patient_cues", []), dominant_patient_state())
	if interaction.is_empty():
		return false
	active_patient_interaction = interaction.duplicate(true)
	patient_interaction_history.append(str(interaction.id))
	awaiting_patient_choice = true
	feedback = str(interaction.prompt)
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	return true

func complete_surgery_flow_stage() -> void:
	procedure_step_index += 1
	if procedure_step_index >= surgery_flow_steps().size() and not flags.has("procedure_flow_complete"):
		flags.append("procedure_flow_complete")
		# The old fixed interlude path set this flag on its final dialogue choice.
		# Dynamic patient events now live inside surgery_flow, so completing the
		# final flow stage is the single source of truth for that requirement.
		if not flags.has("interaction_complete"):
			flags.append("interaction_complete")
	stage_id = pending_flow_stage_id
	pending_flow_stage_id = ""
	pending_flow_retry = false
	active_patient_interaction.clear()
	awaiting_patient_choice = false
	awaiting_patient_acknowledgement = false
	last_staff_id = ""
	last_staff_role = ""
	feedback = ""
	feedback_speaker = "narrator"

func duration_text(value: int) -> String:
	if value % 60 == 0:
		return "%s小时" % (value / 60)
	if value > 60:
		return "%s小时%s分钟" % [value / 60, value % 60]
	return "%s分钟" % value

func team_ready() -> bool:
	var used: Array = []
	for role in definition.roles:
		var id: String = team.get(role.id, "")
		if not qualified(id, role) or used.has(id):
			return false
		used.append(id)
	return true

func action_reason(action: Dictionary) -> String:
	if not action_visible(action):
		return "这项选择当前不可用"
	if done.has(action.id):
		return "已完成"
	for required in action.requires:
		if not flags.has(required):
			return "请先完成前面的准备"
	if action.requires_team and not team_ready():
		return "请选齐三个不同的团队成员"
	if action.get("requires_ward_nurse", false) and not team.has(definition.ward_role.id):
		return "请先指派病房准备护士"
	if action.execute_preparation and not team.has(definition.ward_role.id):
		return "请指派病房准备护士"
	return ""

func action_visible(action: Dictionary) -> bool:
	for required in action.get("show_if_flags", []):
		if not flags.has(required):
			return false
	for excluded in action.get("hide_if_flags", []):
		if flags.has(excluded):
			return false
	return true

func apply(event: Variant) -> bool:
	last_error = "这项操作当前不可用。"
	if not event is Dictionary or not event.get("kind") is String:
		return false
	match event.kind:
		"procedure":
			if event.size() != 2 or not event.get("id") is String or current().kind != "surgery_select" or not procedure_id.is_empty():
				return false
			if not surgeries.has(event.id):
				return false
			var surgery: Dictionary = surgeries[event.id]
			last_staff_id = ""
			last_staff_role = ""
			procedure_id = surgery.id
			procedure_name = surgery.name
			procedure_minutes = int(surgery.duration_minutes)
			procedure_step_index = 0
			procedure_step_history.clear()
			procedure_corrections = 0
			awaiting_flow_acknowledgement = false
			awaiting_patient_choice = false
			awaiting_patient_acknowledgement = false
			active_patient_interaction.clear()
			patient_interaction_history.clear()
			pending_flow_stage_id = ""
			pending_flow_retry = false
			procedure_mismatch = procedure_id != str(definition.surgery_id)
			if procedure_mismatch:
				flags.append("wrong_procedure_selected")
				fear = clampi(fear + 40, 0, 100)
				feedback = patient_reaction("procedure_mismatch", "「不、不是吧，医生？我不是要做那里……！」")
				feedback_speaker = "patient"
				stage_id = "procedure_mismatch"
			else:
				feedback = "已确认本次术式：%s。接下来进行麻醉准备。" % procedure_name
				feedback_speaker = "narrator"
				stage_id = current().next
		"legacy_surgery_bridge":
			if event.size() != 1 or current().kind != "surgery_flow" or flags.has("legacy_patient_interactions_complete"):
				return false
			flags.append("legacy_patient_interactions_complete")
			if not flags.has("interaction_complete"):
				flags.append("interaction_complete")
			feedback = "旧版存档中的患者互动已经完成，继续术式流程。"
			feedback_speaker = "narrator"
		"surgery_step":
			if event.size() != 2 or not event.get("id") is String or current().kind != "surgery_flow" or awaiting_flow_acknowledgement or awaiting_patient_choice or awaiting_patient_acknowledgement:
				return false
			var flow_step: Dictionary = surgery_flow_step()
			if flow_step.is_empty():
				return false
			var selected_option: Dictionary = {}
			for option in flow_step.options:
				if option.id == event.id:
					selected_option = option
					break
			if selected_option.is_empty():
				return false
			last_staff_role = str(selected_option.response_role)
			if not team.has(last_staff_role):
				return false
			last_staff_id = str(team[last_staff_role])
			var was_correct: bool = bool(selected_option.correct)
			if was_correct:
				feedback = roster[last_staff_id].name + "：" + intraoperative_response(last_staff_id, str(selected_option.id), str(selected_option.response), false)
			else:
				last_staff_role = "assistant_surgeon"
				last_staff_id = str(team.get(last_staff_role, ""))
				if last_staff_id.is_empty():
					return false
				procedure_corrections += 1
				feedback = roster[last_staff_id].name + "：" + intraoperative_response(last_staff_id, str(selected_option.id), str(selected_option.correction), true)
			feedback_speaker = "staff"
			procedure_step_history.append({"stage_id": flow_step.id, "option_id": selected_option.id, "correct": was_correct})
			pending_flow_retry = not was_correct
			if pending_flow_retry:
				# A correction is feedback, not completion of the surgical step. The
				# player returns to the same options after acknowledging the assistant.
				pending_flow_stage_id = stage_id
			else:
				var flow_next: String = str(current().next)
				pending_flow_stage_id = flow_next if procedure_step_index + 1 >= surgery_flow_steps().size() else stage_id
			awaiting_flow_acknowledgement = true
		"flow_acknowledge":
			if event.size() != 1 or current().kind != "surgery_flow" or not awaiting_flow_acknowledgement or pending_flow_stage_id.is_empty():
				return false
			awaiting_flow_acknowledgement = false
			last_staff_id = ""
			last_staff_role = ""
			feedback = ""
			feedback_speaker = "narrator"
			if pending_flow_retry:
				stage_id = pending_flow_stage_id
				pending_flow_stage_id = ""
				pending_flow_retry = false
			elif not resolve_patient_event_for_stage():
				complete_surgery_flow_stage()
		"patient_interaction_action":
			if event.size() != 2 or not event.get("id") is String or current().kind != "surgery_flow" or not awaiting_patient_choice or active_patient_interaction.is_empty():
				return false
			var selected_action: Dictionary = {}
			for action in active_patient_interaction.get("actions", []):
				if str(action.id) == str(event.id):
					selected_action = action
					break
			if selected_action.is_empty() or not str(selected_action.get("delegate_role", "")).is_empty():
				return false
			minutes += int(selected_action.minutes)
			var interaction_effects: Dictionary = selected_action.get("effects", {})
			fear = clampi(fear + int(interaction_effects.get("fear", 0)), 0, 100)
			pain = clampi(pain + int(interaction_effects.get("pain", 0)), 0, 100)
			dignity = clampi(dignity + int(interaction_effects.get("dignity", 0)), 0, 100)
			cooperation_base = clampi(cooperation_base + int(interaction_effects.get("cooperation", 0)), 0, 100)
			feedback = str(selected_action.response)
			feedback_speaker = str(selected_action.response_speaker)
			awaiting_patient_choice = false
			awaiting_patient_acknowledgement = true
		"patient_acknowledge":
			if event.size() != 1 or current().kind != "surgery_flow" or not awaiting_patient_acknowledgement:
				return false
			if pending_flow_stage_id.is_empty():
				# The incision action can enter surgery_flow with a patient response
				# already on screen. Acknowledging that entry response only reveals the
				# first technical step; no surgery-flow stage has been completed yet.
				awaiting_patient_acknowledgement = false
				active_patient_interaction.clear()
				feedback = ""
				feedback_speaker = "narrator"
			else:
				complete_surgery_flow_stage()
		"assign":
			if event.size() != 3 or not event.get("role") is String or not event.get("staff_id") is String:
				return false
			var role := role_definition(event.role)
			var is_ward: bool = event.role == definition.ward_role.id
			if (is_ward and current().kind != "preparation") or (not is_ward and current().kind != "team"):
				return false
			if not qualified(event.staff_id, role) or team.get(event.role) == event.staff_id:
				return false
			for other in team:
				if other != event.role and team[other] == event.staff_id:
					last_error = "同一位同事不能同时承担两个岗位。"
					return false
			team[event.role] = event.staff_id
			last_staff_id = event.staff_id
			last_staff_role = event.role
			feedback = "%s：%s" % [roster[event.staff_id].name, assignment_response(event.role, event.staff_id)]
			feedback_speaker = "staff"
		"toggle":
			if event.size() != 2 or not event.get("id") is String or current().kind != "preparation":
				return false
			var item := preparation(event.id)
			if item.is_empty():
				return false
			if selected_preparations.has(event.id):
				selected_preparations.erase(event.id)
			else:
				if selected_preparations.size() >= definition.max_optional_preparations:
					last_error = "额外照顾最多选择两项。"
					return false
				selected_preparations.append(event.id)
			feedback = ""
			feedback_speaker = "narrator"
		"action":
			if not event.get("id") is String or not (event.size() in [2, 3]):
				return false
			var action := {}
			for item in current().actions:
				if item.id == event.id:
					action = item
			if action.is_empty():
				return false
			var makes_incision: bool = action.get("flags", []).has("incision_made")
			var supplied_background: String = str(event.get("operative_background_id", ""))
			if event.size() == 3 and (not makes_incision or not event.has("operative_background_id") or not OperativeBackgrounds.valid(supplied_background)):
				return false
			if current().kind == "surgery_execute" and (procedure_id.is_empty() or surgery_success):
				return false
			last_error = action_reason(action)
			if not last_error.is_empty():
				return false
			last_staff_id = ""
			last_staff_role = ""
			done.append(action.id)
			minutes += int(action.minutes)
			anxiety = clampi(anxiety - int(action.calm), 0, 3)
			for flag in action.flags:
				if not flags.has(flag):
					flags.append(flag)
			if makes_incision:
				# New saves record a random selection on the incision event. Old saves
				# receive a deterministic fallback so replay remains stable.
				operative_background_id = supplied_background if not supplied_background.is_empty() else str(OperativeBackgrounds.IDS[0])
			for flag in action.get("clear_flags", []):
				flags.erase(flag)
			if action.get("reset_procedure", false):
				procedure_id = ""
				procedure_name = ""
				procedure_minutes = 0
				procedure_mismatch = false
				procedure_step_index = 0
				procedure_step_history.clear()
				procedure_corrections = 0
				awaiting_flow_acknowledgement = false
				awaiting_patient_choice = false
				awaiting_patient_acknowledgement = false
				active_patient_interaction.clear()
				patient_interaction_history.clear()
				pending_flow_stage_id = ""
				pending_flow_retry = false
			var profile_effects: Dictionary = action.get("player_effects", {})
			if not profile_effects.is_empty():
				for metric in player_effects:
					player_effects[metric] = int(player_effects[metric]) + int(profile_effects.get(metric, 0))
				player_effect_history.append({"id": action.id, "label": action.label, "effects": profile_effects.duplicate(true)})
			if action.has("anesthesia"):
				anesthesia = str(action.anesthesia)
			var effects: Dictionary = action.get("effects", {})
			fear = clampi(fear + int(effects.get("fear", 0)), 0, 100)
			pain = clampi(pain + int(effects.get("pain", 0)), 0, 100)
			dignity = clampi(dignity + int(effects.get("dignity", 0)), 0, 100)
			cooperation_base = clampi(cooperation_base + int(effects.get("cooperation", 0)), 0, 100)
			feedback = patient_reaction(str(action.id), str(action.response))
			feedback_speaker = str(action.response_speaker)
			var preparation_reaction_id := operative_preparation_reaction_id(str(action.id))
			if not preparation_reaction_id.is_empty():
				feedback = patient_reaction(preparation_reaction_id, operative_preparation_fallback(str(action.id)))
				feedback_speaker = "patient"
			if current().kind == "surgery_execute" and action.id == "execute_confirmed_procedure":
				minutes += procedure_minutes
				surgery_success = true
				flags.append("surgery_success")
				player_effects.skill = int(player_effects.skill) + 2
				player_effect_history.append({"id": "successful_surgery", "label": "成功完成手术", "effects": {"skill": 2}})
				feedback = "%s历时%s，顺利完成。患者%s的状态%s。" % [procedure_name, duration_text(procedure_minutes), patient_name, postoperative_state_text()]
				feedback_speaker = "narrator"
			if action.execute_preparation:
				for id in selected_preparations:
					var item := preparation(id)
					minutes += int(item.minutes)
					anxiety = clampi(anxiety - int(item.calm), 0, 3)
				var nurse: Dictionary = roster[team[definition.ward_role.id]]
				if nurse.skills.patient_care >= definition.care_reassurance_threshold:
					anxiety = maxi(0, anxiety - 1)
			var response_role: String = action.get("response_role", "")
			if team.has(response_role):
				var actor_id: String = team[response_role]
				last_staff_id = actor_id
				last_staff_role = response_role
				var authored_response := str(action.get("response_by_staff", {}).get(actor_id, feedback))
				feedback = roster[actor_id].name + "：" + staff_action_response(actor_id, str(action.id), authored_response)
				feedback_speaker = "staff"
			if action.id == "assistant_stabilize" and not flags.has("anesthetized"):
				var stabilization_reaction_id := "assistant_stabilize_none" if flags.has("no_anesthesia_confirmed") else "assistant_stabilize_local" if flags.has("local_anesthesia") else "assistant_stabilize_epidural"
				var stabilization_fallback := "「别按那里——很痛！我会努力不动，可是请不要突然用力……！」" if stabilization_reaction_id.ends_with("none") else "「我感觉到你们固定住那里了……请告诉我什么时候会下刀。」"
				feedback += "\n%s：%s" % [patient_name, patient_reaction(stabilization_reaction_id, stabilization_fallback)]
			if action.next != null:
				var action_next: String = str(action.next)
				if action.id == "begin_manual_ward_preparation":
					action_next = "ward_enema"
				if action.id in ["induction_reassure", "induction_brief", "choose_epidural", "choose_local", "insist_without_anesthesia"]:
					action_next = "operative_positioning"
				stage_id = action_next
				if current().kind == "surgery_flow" and not feedback.is_empty():
					awaiting_patient_acknowledgement = true
		_:
			return false
	events.append(event.duplicate(true))
	last_error = ""
	return true

func staff_has_low_surgery_proficiency(staff_id: String) -> bool:
	return str(roster.get(staff_id, {}).get("surgery_proficiency", "trained")) in ["novice", "limited"]

func inexperienced_nurse_response(staff_id: String, response_id: String, fallback: String) -> String:
	var staff_member: Dictionary = roster.get(staff_id, {})
	if str(staff_member.get("profession", "")) != "nurse" or not staff_has_low_surgery_proficiency(staff_id):
		return fallback
	var proficiency := str(staff_member.get("surgery_proficiency", "trained"))
	for profile in surgery_team_dialogue_profiles:
		if str(profile.get("profession", "")) != "nurse" or proficiency not in profile.get("proficiencies", []):
			continue
		var variants: Variant = profile.get("responses", {}).get(response_id, [])
		if variants is Array and not variants.is_empty():
			var variation_seed := "%s:%s:%s:%s:%s" % [staff_id, patient_name, procedure_id, response_id, events.size()]
			return str(variants[posmod(hash(variation_seed), variants.size())])
	return fallback

func intraoperative_response(staff_id: String, response_id: String, authored: String, correction: bool) -> String:
	if not staff_has_low_surgery_proficiency(staff_id):
		return authored
	if str(roster.get(staff_id, {}).get("profession", "")) == "nurse":
		var nurse_fallback := "「我不敢确定这一步，请本多医生再核对一次。」" if correction else "「我对手术室流程不熟，这一步做完了，但请本多医生再确认。」"
		return inexperienced_nurse_response(staff_id, response_id, nurse_fallback)
	var dialogue_key := "intraoperative_correction" if correction else "intraoperative"
	var custom := str(roster[staff_id].get("team_dialogue", {}).get(dialogue_key, ""))
	if not custom.is_empty():
		return custom
	if correction:
		return "「我不敢确定，但这一步和术前核对不一致。请你重新确认。」"
	return "「我对术野不熟，只能按你的指示配合。这一步已经完成，请你再确认。」"

func assignment_response(role_id: String, staff_id: String = "") -> String:
	if not staff_id.is_empty() and staff_has_low_surgery_proficiency(staff_id):
		if str(roster.get(staff_id, {}).get("profession", "")) == "nurse":
			return inexperienced_nurse_response(staff_id, "assignment_" + role_id, "「我不太擅长手术配合……既然需要，我会试试。请把每一步说清楚。」")
		var custom := str(roster[staff_id].get("team_dialogue", {}).get("assignment", ""))
		if not custom.is_empty():
			return custom
		return "「我不太擅长手术配合……既然你需要，我会勉强试试。请把每一步说清楚。」"
	match role_id:
		"assistant_surgeon":
			return "「我来担任助手。术前计划再和你核对一遍。」"
		"scrub_nurse":
			return "「器械护士由我负责，清点会提前完成。」"
		"circulating_nurse":
			return "「我负责巡回与记录，有变化会立刻报告。」"
		"ward_nurse":
			return "「病房准备交给我，我会再向她解释一遍。」"
	return "「收到，我会做好准备。」"

func staff_action_response(staff_id: String, action_id: String, authored: String) -> String:
	if str(roster.get(staff_id, {}).get("profession", "")) == "nurse" and staff_has_low_surgery_proficiency(staff_id):
		var nurse_fallback := "「这个步骤我不太熟，请本多医生再确认一次。」"
		return inexperienced_nurse_response(staff_id, action_id, nurse_fallback)
	var dialogue_key := str({
		"confirm_team": "confirmation",
		"confirm_assistant_role": "role_confirmation",
		"assistant_stabilize": "stabilize"
	}.get(action_id, ""))
	if dialogue_key.is_empty():
		return authored
	var custom := str(roster.get(staff_id, {}).get("team_dialogue", {}).get(dialogue_key, ""))
	return authored if custom.is_empty() else custom

func presentation_staff() -> Dictionary:
	return roster.get(last_staff_id, {})

func presentation_staff_role() -> String:
	var role := role_definition(last_staff_role)
	return str(role.get("label", "团队成员"))

func patient_reaction(reaction_id: String, fallback: String) -> String:
	# Patient-authored variants are presentation only. Numeric effects and routing
	# continue to come from the shared action, so personality cannot change outcome.
	var variants: Variant = patient_reaction_variants.get(reaction_id, [])
	if variants is Array and not variants.is_empty():
		var variant_index := posmod(hash("%s:%s:%s" % [patient_name, reaction_id, events.size()]), variants.size())
		return str(variants[variant_index])
	return str(patient_reactions.get(reaction_id, fallback))

func operative_preparation_reaction_id(action_id: String) -> String:
	if flags.has("anesthetized") or action_id not in ["operative_positioning", "urinary_catheterization", "skin_disinfection", "incision_marking"]:
		return ""
	return action_id + ("_none" if flags.has("no_anesthesia_confirmed") else "_awake")

func operative_preparation_fallback(action_id: String) -> String:
	var without_anesthesia := flags.has("no_anesthesia_confirmed")
	match action_id:
		"operative_positioning":
			return "「不要固定我的手……我的腿也必须保持这个角度吗？」" if without_anesthesia else "「固定带有一点紧……我会尽量保持不动。」"
		"urinary_catheterization":
			return "「啊……好难受，请停一下！」" if without_anesthesia else "「有些不舒服……请慢一点，我会配合。」"
		"skin_disinfection":
			return "「又冷又刺，皮肤已经被擦得发疼了！」" if without_anesthesia else "「消毒液很凉……我会忍住不动。」"
		"incision_marking":
			return "「这么长的线……真的要全部切开吗？先停下！」" if without_anesthesia else "「切口线比我想象得长……真的需要这么大吗？」"
	return ""

func patient_trait(id: String, fallback: int = 50) -> int:
	return clampi(int(patient_traits.get(id, fallback)), 0, 100)

func stress_response_text() -> String:
	match str(patient_personality.get("stress_response", "")):
		"becomes_quiet":
			return "沉默收缩"
		"seeks_reassurance":
			return "寻求确认"
		"becomes_irritable":
			return "急切外露"
		"asks_for_details":
			return "反复确认"
	return "压力明显"

func preparation(id: String) -> Dictionary:
	for item in definition.preparations:
		if item.id == id:
			return item
	return {}

func mood_text() -> String:
	return ["比较安心", "仍有些忐忑", "紧张", "非常紧张"][anxiety]

func cooperation_value() -> int:
	if flags.has("anesthetized"):
		return 100
	var penalty := 0
	if fear >= 80:
		penalty += 30
	if pain >= 75:
		penalty += 35
	if dignity <= 25:
		penalty += 25
	return clampi(cooperation_base - penalty, 0, 100)

func patient_state_text() -> String:
	if flags.has("anesthetized"):
		return "麻醉中 · 反应平稳"
	if cooperation_value() <= 30:
		return "接近失去配合 · " + stress_response_text()
	if fear >= 70 or pain >= 70:
		return "明显恐惧 · " + stress_response_text()
	if fear >= 40:
		return "紧张但仍在配合"
	return "状态相对平稳"

func interaction_summary() -> String:
	var procedure_summary := "%s历时%s，顺利完成。患者%s的状态%s。\n" % [procedure_name, duration_text(procedure_minutes), patient_name, postoperative_state_text()] if surgery_success else ""
	if procedure_corrections > 0:
		procedure_summary += "术中有%s项判断由助手及时纠正。\n" % procedure_corrections
	if procedure_mismatch:
		procedure_summary = "选择的术式与患者原定手术不符。患者受到惊吓，恐惧大幅上升。\n" + procedure_summary
	if flags.has("anesthetized"):
		return procedure_summary + "患者在全身麻醉下平稳度过互动阶段。你在诱导前的回应仍影响了她最后的感受。"
	if cooperation_value() <= 30:
		return procedure_summary + "患者勉强完成配合，但恐惧、痛苦或尊严压力已经超过临界点。"
	if fear <= 35 and dignity >= 80:
		return procedure_summary + "患者始终知道下一步会发生什么，也感到自己的感受被认真对待。"
	if cooperation_value() >= 70:
		return procedure_summary + "患者带着明显紧张完成了配合；你的回应维持了互动的稳定。"
	return procedure_summary + "互动阶段结束。患者完成了配合，但仍留下了一些不安。"

func postoperative_state_text() -> String:
	# Placeholder seam for later rules based on vitals and patient experience.
	return "暂时平稳"

func patient_visual_state() -> String:
	if current().scene == "operating_room":
		return "operating_room"
	return "preoperative" if flags.has("patient_prepared") else "gown"

func staff_outfit() -> String:
	return "scrubs" if flags.has("changed") else "default"

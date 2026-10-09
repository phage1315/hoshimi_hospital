extends RefCounted
const Progression = preload("res://godot/systems/progression_config.gd")
## Preoperative narrative state. Authored data owns dialogue, tasks and transitions.
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")
const POSTOPERATIVE_WRAP_UP_MINUTES := 30
const OR_TABLE_PALPATION_CG_IDS := ["prototype_v1", "body_type_02", "body_type_03", "body_type_04"]
const CRISIS_FLAVOR_IDS := [
	"hypotension",
	"hypertension",
	"tachycardia",
	"bradycardia",
	"arrhythmia",
	"desaturation",
	"respiratory_instability",
	"generic_instability",
]
const GENERIC_CRISIS_CALLOUTS_ZH := {
	"hypotension": ["血压开始下降。", "血压还在往下。", "血压已经太低了，必须马上控制住！"],
	"hypertension": ["血压正在升高。", "血压继续上升。", "血压已经高得危险，必须马上处理！"],
	"tachycardia": ["心率开始加快。", "心率还在继续升高。", "心率已经过快，不能再等！"],
	"bradycardia": ["心率开始下降。", "心率还在继续下降。", "心率已经太低了，立即处理！"],
	"arrhythmia": ["心律出现异常。", "心律紊乱正在加重。", "心律已经非常不稳定，立即处理！"],
	"desaturation": ["血氧开始下降。", "血氧还在继续下降。", "血氧已经太低了，立即处理！"],
	"respiratory_instability": ["呼吸参数出现波动。", "通气情况正在恶化。", "呼吸已经非常不稳定，立即处理！"],
	"generic_instability": ["生命体征出现波动。", "患者状态还在恶化。", "生命体征已经非常不稳定，立即处理！"],
}
const GENERIC_CRISIS_CALLOUTS_EN := {
	"hypotension": ["Blood pressure is falling.", "Blood pressure is still falling.", "Blood pressure is dangerously low. We need to act now!"],
	"hypertension": ["Blood pressure is rising.", "Blood pressure is continuing to rise.", "Blood pressure is dangerously high. We need to act now!"],
	"tachycardia": ["Heart rate is rising.", "Heart rate is still climbing.", "The heart rate is dangerously high. We cannot wait!"],
	"bradycardia": ["Heart rate is falling.", "Heart rate is still falling.", "The heart rate is dangerously low. Act now!"],
	"arrhythmia": ["The rhythm is becoming irregular.", "The arrhythmia is getting worse.", "The rhythm is critically unstable. Act now!"],
	"desaturation": ["Oxygen saturation is falling.", "Oxygen saturation is still falling.", "Oxygen saturation is dangerously low. Act now!"],
	"respiratory_instability": ["The respiratory readings are fluctuating.", "Ventilation is deteriorating.", "Respiration is critically unstable. Act now!"],
	"generic_instability": ["The vital signs are becoming unstable.", "The patient's condition is still deteriorating.", "The vital signs are critically unstable. Act now!"],
}
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
var unlocked_procedure_ids: Array[String] = []
var enforce_procedure_unlocks := false
var surgery_team_dialogue_profiles: Array = []
var patient_interactions: Array = []
var temporary_condition_definitions: Dictionary = {}
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
var procedure_extra_minutes := 0
var surgery_success := false
var surgery_aborted := false
var procedure_mismatch := false
var procedure_step_index := 0
var procedure_step_history: Array[Dictionary] = []
var procedure_corrections := 0
var procedure_state: Dictionary = {}
var bleeding := 0
var minimum_stability_seen := 100
var surgical_complications: Array[Dictionary] = []
var surgical_technical_flags: Array[String] = []
var surgery_rng_seed := 0
var case_variant_id := ""
var resolved_random_choices: Dictionary = {}
var conditional_stage_resolution: Dictionary = {}
var patient_event_consumed_this_stage := false
var last_intrusion_stage_index := -1
var cooperation_disruption_count := 0
var patient_intrusion_history: Array[String] = []
var lowest_dignity_seen := 100
var lowest_cooperation_seen := 100
var peak_fear_seen := 0
var peak_pain_seen := 0
var dignity_intrusion_count := 0
var dignity_break_count := 0
var patient_caused_complication_count := 0
var awaiting_flow_acknowledgement := false
var pending_flow_stage_id := ""
var pending_flow_retry := false
var awaiting_patient_choice := false
var awaiting_patient_acknowledgement := false
var active_patient_interaction: Dictionary = {}
var patient_interaction_history: Array[String] = []
var patient_event_count := 0
var active_temporary_conditions: Dictionary = {}
var active_condition_id := ""
var temporary_conditions_enabled := true
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
var player_effects := {"charm": 0, "presence": 0, "reputation": 0}
var player_effect_history: Array[Dictionary] = []
var presence_preop_raw := 0
var presence_or_raw := 0
var or_table_palpation_counts: Dictionary = {}
var or_table_needle_counts: Dictionary = {}
var anesthesia_test_counts: Dictionary = {}
var sensory_interaction_xp_bonus := 0
var or_table_palpation_cg_id := "prototype_v1"
var palpation_profiles: Dictionary = {}
var palpation_findings_confirmed: Array[String] = []
var last_palpation_confirmation := ""
var active_crisis: Dictionary = {}
var awaiting_crisis_acknowledgement := false
var crisis_history: Array[Dictionary] = []
var graphic_preop_explainer_id := "doc_aoi"
var graphic_preop_nodes: Array[Dictionary] = []
var graphic_preop_node_index := -1

func english_mode() -> bool:
	return str(definition.get("_locale", "zh_CN")) == "en" if definition != null else false

func runtime_english(value: Variant) -> Variant:
	if not english_mode():
		return value
	if value is Dictionary:
		var localized: Dictionary = {}
		for key in value:
			localized[key] = runtime_english(value[key])
		return localized
	if value is Array:
		var localized: Array = []
		for entry in value:
			localized.append(runtime_english(entry))
		return localized
	if not value is String:
		return value
	var phrases := {
		"手术台术前触诊":"Operating-Table Palpation", "在麻醉选择前完成手术台触诊。选择力度后，直接点击患者身体上的检查区域。":"Complete operating-table palpation before selecting anesthesia. Choose the pressure level, then click the examination area directly.",
		"未消毒、未麻醉的切入":"Unprepared Incision", "刀刃碰到身体的瞬间，患者因剧痛尖叫。巡回护士立刻制止了你。":"The moment the blade touches her body, the patient screams in pain. The circulating nurse stops you at once.",
		"听取护士警告，立即选择麻醉  →":"Heed the nurse's warning and select anesthesia  →", "「医生！你怎么能不消毒、不麻醉就下刀呢？！」":"“Doctor! How could you make an incision without antisepsis or anesthesia?!”",
		"手术中止 · 支援已到场":"Procedure Aborted · Support Arrived", "当前团队无法继续稳定患者。追加支援到场后，患者情况已经稳定，但原定手术必须中止。":"The current team cannot restore safe operating conditions. Additional support stabilizes the patient, but the planned procedure must be aborted.",
		"暂停操作，全力稳定患者":"Pause and fully stabilize the patient", "保持当前术野，让团队处理":"Hold the field and let the team respond", "先完成当前关键动作再处理":"Finish the critical action before responding",
		"体位摆放与固定":"Positioning and Restraint", "固定后的回应":"Positioning Confirmed",
		"体位与固定已经确认。":"Positioning and pressure-point protection are confirmed.", "继续：留置导尿":"Continue: urinary catheterization",
		"留置导尿":"Urinary Catheterization", "导尿后的回应":"Catheterization Confirmed", "留置导尿已经完成。":"Urinary catheterization is complete.", "继续：术野消毒":"Continue: skin antisepsis",
		"术野消毒":"Skin Antisepsis", "消毒后的回应":"Antisepsis Confirmed", "术野消毒已经完成并充分干燥。":"The operative field has been disinfected and allowed to dry.", "继续：复核切口划线":"Continue: verify incision marking",
		"切口划线":"Incision Marking", "划线后的回应":"Incision Marking Confirmed", "切口范围已经复核，接下来可以正式开始手术。":"The incision has been verified. Surgery may now begin.", "完成准备，进入开始手术":"Complete preparation and begin surgery",
		"开始手术":"Begin Surgery", "四项术前准备已经完成。患者仍在清醒状态下明显抗拒，团队等待你的最终命令。":"All four preoperative steps are complete. The awake patient remains visibly resistant while the team awaits your final order.",
		"坚持继续，命令：“开始手术。手术刀。”":"Insist on continuing: “Begin surgery. Scalpel.”", "你再次确认决定，随即向团队下令：「开始手术。手术刀。」":"You confirm the decision once more and order, “Begin surgery. Scalpel.”",
		"团队依据术式调整仰卧体位，在肩、肘、髋与足跟下加软垫保护受压点；双臂与腿部被安置到预定角度，再用安全固定带限制意外移动。":"The team places the patient supine, pads the shoulders, elbows, hips, and heels, then secures the limbs at the planned angles.",
		"确认受压点保护，完成体位固定":"Confirm pressure-point protection and secure the position", "确认受压点保护，完成仰卧位固定":"Confirm pressure-point protection and complete supine positioning",
		"团队托住肩、髋与四肢完成调整，软垫和安全固定带逐一就位。患者在全身麻醉下没有意识反应。":"The team supports the shoulders, hips, and limbs while placing each pad and safety strap. The patient shows no conscious response under general anesthesia.",
		"团队托住肩、髋与四肢完成仰卧位调整，软垫和安全固定带逐一就位。患者在全身麻醉下没有意识反应。":"The team completes supine positioning and places each pad and safety strap. The patient shows no conscious response under general anesthesia.",
		"团队依据术式改为截石位：患者的双腿同步抬起，屈髋屈膝后分别放入带软垫的腿架；护士确认骶尾部、腓骨头与足跟没有异常受压，再完成对称固定。":"The team places the patient in lithotomy, lifting both legs together into padded supports and checking the sacrum, fibular heads, and heels before symmetric fixation.",
		"确认腿架与受压点保护，完成截石位固定":"Confirm leg supports and pressure-point protection", "团队同步托起双腿并放入腿架，逐一确认软垫、关节角度与固定带。患者在全身麻醉下没有意识反应。":"The team lifts both legs into the supports and verifies the padding, joint angles, and straps. The patient shows no conscious response under general anesthesia.",
		"巡回护士核对导尿用品，在保护隐私的同时显露必要范围，以无菌方式清洁并置入导尿管，供长时间手术监测尿量与膀胱引流。":"The circulating nurse verifies the supplies, exposes only the necessary area, performs sterile cleansing, and inserts a urinary catheter for drainage and output monitoring.",
		"确认无菌操作，完成留置导尿":"Confirm sterile technique and complete catheterization", "巡回护士完成无菌清洁与置管，导尿管固定妥当。患者在全身麻醉下没有意识反应。":"The circulating nurse completes sterile preparation and secures the catheter. The patient shows no conscious response under general anesthesia.",
		"护士再次核对切入部位，从预定切口中心向外分区涂布消毒液；冰凉液体在皮肤上铺开，待覆盖范围完整后自然干燥。":"The nurse verifies the operative site and applies antiseptic outward from the planned incision, then allows the field to dry.",
		"由中心向外完成消毒并等待干燥":"Apply antiseptic outward and allow it to dry", "消毒液均匀覆盖预定术野，在灯光下留下短暂的湿润光泽。患者在全身麻醉下没有意识反应。":"Antiseptic evenly covers the operative field and briefly glistens under the lights. The patient shows no conscious response under general anesthesia.",
		"你依据术前已经核对的定位和解剖标志，用无菌皮肤标记笔复核切口走向；笔尖在消毒后的皮肤上留下清晰而克制的线条。":"Using the verified landmarks and operative plan, you trace the incision with a sterile skin marker.",
		"核对解剖标志，完成切口划线":"Verify landmarks and complete the incision marking", "切口线与术前计划一致，团队完成最后一次位置核对。患者在全身麻醉下没有意识反应。":"The marking matches the preoperative plan, and the team completes its final site check. The patient shows no conscious response under general anesthesia.",
		"病房准备 · 灌肠":"Ward Preparation · Enema", "灌肠后的回应":"Enema Complete", "按清单亲手完成灌肠":"Perform the required enema personally", "按清单跳过灌肠":"Skip enema as directed", "跳过灌肠":"Omit the required enema", "仍然执行灌肠":"Perform an unnecessary enema anyway",
		"本次属于开腹或盆腔手术，准备清单要求灌肠。执行时，你会让患者侧卧屈膝，核对液体温度，润滑管端后缓慢置入并分次注入。":"This open abdominal or pelvic operation requires an enema. Position the patient on her side, verify the solution temperature, lubricate the tip, and administer it slowly in stages.",
		"本次手术不涉及腹部或盆腔，准备清单没有要求灌肠。用品仍在推车上；若坚持执行，操作仍包括侧卧置管、分次注入与等待排空。":"This operation does not involve the abdomen or pelvis, so the checklist does not require an enema.",
		"「等、等一下……肚子已经开始胀了。还要忍多久？」":"“W-wait... my abdomen already feels full. How long do I have to hold it?”", "本次术式不要求灌肠，护士在清单上标记为不适用。":"This procedure does not require an enema; the nurse marks it not applicable.",
		"「这项灌肠在开腹或盆腔手术的准备清单里。跳过会增加术中污染和术后感染风险，请你再次确认。」":"“The checklist requires this enema. Omitting it increases contamination and infection risk; please confirm again.”", "「这次不是腹部手术，为什么还要灌肠……？」":"“This is not abdominal surgery... Why do I still need an enema?”",
		"灌肠项目已经处理。护士收走或撤下用物，按刚才的选择在准备记录单上填写结果。":"The enema item has been addressed. The nurse clears the supplies and records the decision.", "继续：备皮":"Continue: skin preparation", "灌肠记录已经核对。":"The enema record has been verified.",
		"病房准备 · 备皮":"Ward Preparation · Skin Preparation", "备皮后的回应":"Skin Preparation Complete", "完成下腹及会阴备皮":"Complete lower-abdominal and perineal skin preparation", "按清单跳过下腹及会阴备皮":"Skip lower-abdominal and perineal preparation as directed", "跳过下腹及会阴备皮":"Omit the required skin preparation", "仍然进行下腹及会阴备皮":"Perform unnecessary lower-abdominal and perineal preparation anyway",
		"本次属于开腹或盆腔手术，准备清单要求下腹及会阴备皮。执行时，你会让患者仰卧并显露下腹、腹股沟和会阴，用电动备皮器逐区剪短毛发。":"This open abdominal or pelvic operation requires lower-abdominal and perineal skin preparation. Position the patient supine and prepare the required field with electric clippers.",
		"本次手术不涉及腹部或盆腔，准备清单没有要求下腹及会阴备皮。若坚持执行，患者仍需仰卧显露下腹、腹股沟和会阴，由你用电动备皮器逐区处理。":"This operation does not involve the abdomen or pelvis, so the checklist does not require lower-abdominal or perineal skin preparation.",
		"「连这里也要备皮吗……我知道了，请继续。」":"“This area too...? I understand. Please continue.”", "本次术式不要求下腹及会阴备皮，护士在清单上标记为不适用。":"This procedure does not require lower-abdominal or perineal preparation; the nurse marks it not applicable.",
		"「下腹及会阴备皮属于这次术野准备。跳过会影响后续消毒和铺单，我建议按清单完成。」":"“This field preparation is required. Omitting it will affect antisepsis and draping; I recommend following the checklist.”", "「明明不是腹部手术，为什么要把下面也处理掉……？」":"“This is not abdominal surgery... Why does that area need to be prepared?”",
		"下腹及会阴备皮项目已经处理。护士按刚才的选择填写结果，再把手术帽放到床边。":"The skin-preparation item has been addressed. The nurse records the decision and places a surgical cap by the bed.", "继续：戴手术帽":"Continue: surgical cap", "术野备皮已经完成。":"Skin preparation is complete.",
		"病房准备 · 戴手术帽":"Ward Preparation · Surgical Cap", "替她拢好头发，戴上手术帽":"Gather her hair and fit the surgical cap", "「这样就要去手术室了吗……看起来真的像个要被推去开刀的病人了。」":"“So I am going to the operating room now... I really look like a surgical patient.”",
		"你接过护士递来的手术帽，站到患者身后，将她的头发从颈侧和耳边拢起，一缕一缕收进帽内；确认发尾全部包住后，你沿帽缘按了一圈。":"You take the surgical cap, gather the patient's hair from her neck and ears, tuck every strand inside, and check the edge.",
		"病房准备完成":"Ward Preparation Complete", "把担架车交给病房护士":"Hand the stretcher to the ward nurse", "「接下来交给我，我会推她去手术室。」":"“I will take over from here and bring her to the operating room.”",
		"病房准备已经完成。护士用清洁床单遮盖患者，再扶她躺上已经推到床边的担架车；随后拉好护栏、整理输液管路，等着接手送往手术室。":"Ward preparation is complete. The nurse covers the patient with a clean sheet, helps her onto the stretcher, raises the rails, and arranges the IV tubing.",
		"「等等，这项灌肠在准备清单里。跳过会增加污染和感染风险……真的要省略吗？」":"“This is on the checklist. Omitting it raises contamination and infection risk—are you sure?”", "「我反对跳过。清单要求完成灌肠，省略会增加污染与术后感染风险。」":"“I advise against omission. The checklist requires it, and skipping it increases infection risk.”", "「医生，这项不能随便省呀。跳过灌肠会增加污染和感染风险，请再确认一次。」":"“Doctor, this should not be omitted casually. Please confirm once more.”",
		"「这次要准备下腹和会阴术野。跳过会影响后面的消毒与铺单……还是按清单做吧？」":"“This field requires preparation. Skipping it will affect antisepsis and draping; we should follow the checklist.”", "「下腹及会阴备皮属于本次术野准备。我不建议跳过。」":"“This preparation is part of the operative field. I do not recommend skipping it.”", "「医生，这次真的需要备皮。省掉以后消毒和铺单都会受影响呀。」":"“Doctor, this preparation is required. Omitting it will affect antisepsis and draping.”",
		"「好，接下来交给我。我会慢慢推她去手术室。」":"“All right, I will take over and bring her slowly to the operating room.”", "「准备项目都核对完了。接下来由我把她送到手术室。」":"“Every preparation item is verified. I will bring her to the operating room.”", "「护栏和管路都好了。医生放心，我现在推她去手术室。」":"“The rails and lines are secure. I will take her to the operating room now.”",
	}
	return phrases.get(value, value)

func _init(data: Dictionary, staff: Array, surgery_data: Array = [], patient_data: Array = [], known_staff: Array[String] = [], restrict_known: bool = false, surgery_team_dialogue_data: Array = [], patient_interaction_data: Array = [], temporary_condition_data: Array = [], unlocked_procedures: Array[String] = [], enforce_unlocks: bool = false, palpation_profile_data: Array = []) -> void:
	definition = data
	surgery_team_dialogue_profiles = surgery_team_dialogue_data
	patient_interactions = patient_interaction_data
	for condition in temporary_condition_data:
		temporary_condition_definitions[str(condition.id)] = condition
	for profile in palpation_profile_data:
		palpation_profiles[str(profile.get("id", ""))] = profile
	known_staff_ids = known_staff.duplicate()
	restrict_to_known_staff = restrict_known
	unlocked_procedure_ids = unlocked_procedures.duplicate()
	enforce_procedure_unlocks = enforce_unlocks
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
	stages["or_table_palpation"] = or_table_palpation_stage()
	stages["or_table_scalpel_incident"] = or_table_scalpel_incident_stage()
	stages["anesthesia_sensory_test"] = anesthesia_sensory_test_stage()
	stages["anesthesia_test_scalpel_incident"] = anesthesia_test_scalpel_incident_stage()
	stages["ineffective_epidural_warning"] = ineffective_epidural_warning_stage()
	stages["surgery_abort"] = surgery_abort_stage()
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

func set_procedure_unlocks(ids: Array[String], enforce_unlocks: bool = true) -> void:
	unlocked_procedure_ids = ids.duplicate()
	enforce_procedure_unlocks = enforce_unlocks

func set_graphic_preop_explainer(actor_id: String) -> void:
	if roster.has(actor_id):
		graphic_preop_explainer_id = actor_id

func graphic_preop_dialogue_locked() -> bool:
	return stage_id in ["graphic_preop_question", "graphic_preop_dialogue"]

func graphic_preop_family() -> String:
	var config: Dictionary = definition.get("graphic_preop", {})
	var group_id := active_procedure_group()
	return str(config.get("family_by_procedure_group", {}).get(group_id, "abdominal"))

func graphic_preop_wrapper(slot: String) -> String:
	var config: Dictionary = definition.get("graphic_preop", {})
	var fallback: Dictionary = config.get("default_wrapper", {})
	var person: Dictionary = roster.get(graphic_preop_explainer_id, {})
	var wrapper: Dictionary = person.get("preop_graphic_wrapper", {})
	return str(wrapper.get(slot, fallback.get(slot, "")))

func initialize_graphic_preop_dialogue() -> bool:
	var config: Dictionary = definition.get("graphic_preop", {})
	var family: Dictionary = config.get("families", {}).get(graphic_preop_family(), {})
	var authored_nodes: Array = family.get("nodes", [])
	if authored_nodes.is_empty():
		return false
	graphic_preop_nodes.clear()
	for authored in authored_nodes:
		if not authored is Dictionary:
			continue
		var node: Dictionary = authored.duplicate(true)
		if str(node.get("speaker", "")) == "wrapper":
			node["speaker"] = "explainer"
			node["text"] = graphic_preop_wrapper(str(node.get("slot", "")))
		if not str(node.get("text", "")).is_empty():
			graphic_preop_nodes.append(node)
	if graphic_preop_nodes.is_empty():
		return false
	graphic_preop_node_index = 0
	show_graphic_preop_node()
	return true

func show_graphic_preop_node() -> void:
	if graphic_preop_node_index < 0 or graphic_preop_node_index >= graphic_preop_nodes.size():
		return
	var node: Dictionary = graphic_preop_nodes[graphic_preop_node_index]
	var speaker := str(node.get("speaker", "narrator"))
	feedback = str(node.get("text", ""))
	last_staff_role = "Pre-op Explanation" if english_mode() else "术前说明"
	last_staff_id = graphic_preop_explainer_id if speaker == "explainer" else ""
	feedback_speaker = "staff" if speaker == "explainer" else "patient" if speaker == "patient" else "narrator"

func complete_graphic_preop_dialogue() -> void:
	graphic_preop_nodes.clear()
	graphic_preop_node_index = -1
	last_staff_id = ""
	last_staff_role = ""
	feedback = ""
	feedback_speaker = "narrator"
	stage_id = "team"
	if not flags.has("preop_graphic_explanation_complete"):
		flags.append("preop_graphic_explanation_complete")

func procedure_unlocked(id: String) -> bool:
	if not surgeries.has(id) or str(surgeries[id].get("status", "ready")) == "placeholder":
		return false
	return not enforce_procedure_unlocks or unlocked_procedure_ids.has(id)

func procedure_lock_reason(id: String) -> String:
	if not surgeries.has(id):
		return "术式资料不存在。"
	if str(surgeries[id].get("status", "ready")) == "placeholder":
		return "占位术式：手术步骤与正式解锁事件尚未完成。"
	if not procedure_unlocked(id):
		return "尚未解锁。需要通过实际临床参与学习该术式。"
	return ""

func current() -> Dictionary:
	return stages[stage_id]

func or_table_palpation_stage() -> Dictionary:
	return runtime_english({
		"id": "or_table_palpation",
		"title": "手术台术前触诊",
		"scene": "operating_room",
		"kind": "or_table_palpation",
		"prompt": "在麻醉选择前完成手术台触诊。选择力度后，直接点击患者身体上的检查区域。",
		"speaker": "narrator",
		"next": "ready",
		"actions": [],
		"background_id": "operating_room",
	})

func or_table_scalpel_incident_stage() -> Dictionary:
	return runtime_english({
		"id": "or_table_scalpel_incident",
		"title": "未消毒、未麻醉的切入",
		"scene": "operating_room",
		"kind": "interaction",
		"prompt": "刀刃碰到身体的瞬间，患者因剧痛尖叫。巡回护士立刻制止了你。",
		"speaker": "patient",
		"next": "ready",
		"background_id": "operating_room",
		"actions": [{
			"id": "acknowledge_or_table_scalpel_incident",
			"label": "听取护士警告，立即选择麻醉  →",
			"response": "「医生！你怎么能不消毒、不麻醉就下刀呢？！」",
			"response_speaker": "staff",
			"response_role": "circulating_nurse",
			"next": "ready",
			"requires": [],
			"flags": ["or_table_scalpel_warning_acknowledged"],
			"calm": 0,
			"minutes": 0,
			"requires_team": false,
			"execute_preparation": false,
			"effects": {},
		}],
	})

func anesthesia_sensory_test_stage() -> Dictionary:
	return {
		"id": "anesthesia_sensory_test",
		"title": "Anesthesia Sensory Test" if english_mode() else "麻醉感觉测试",
		"scene": "operating_room",
		"kind": "anesthesia_sensory_test",
		"prompt": "Optionally confirm which areas retain sharp sensation. Testing does not change the anesthetic effect." if english_mode() else "可选择确认哪些区域仍保留锐痛觉。测试本身不会改变麻醉效果。",
		"speaker": "narrator",
		"next": "operative_positioning",
		"actions": [],
		"background_id": "operating_room",
	}

func anesthesia_test_scalpel_incident_stage() -> Dictionary:
	return {
		"id": "anesthesia_test_scalpel_incident",
		"title": "Sensory Test Ended" if english_mode() else "麻醉测试中止",
		"scene": "operating_room",
		"kind": "interaction",
		"prompt": "The circulating nurse immediately stops the test." if english_mode() else "巡回护士立即制止了这次测试。",
		"speaker": "staff",
		"next": "operative_positioning",
		"background_id": "operating_room",
		"actions": [{
			"id": "acknowledge_anesthesia_test_scalpel",
			"label": "End the test and continue preparation  →" if english_mode() else "结束测试，继续术前准备  →",
			"response": "“Doctor! This is a sensory test, not the formal incision—and the field has not been disinfected!”" if english_mode() else "「医生！这只是感觉测试，不是正式切皮——而且术区还没有消毒！」",
			"response_speaker": "staff",
			"response_role": "circulating_nurse",
			"next": "operative_positioning",
			"requires": [],
			"flags": ["anesthesia_sensory_test_complete"],
			"calm": 0,
			"minutes": 0,
			"requires_team": false,
			"execute_preparation": false,
			"effects": {},
		}],
	}

func ineffective_epidural_warning_stage() -> Dictionary:
	return {
		"id": "ineffective_epidural_warning",
		"title": "Epidural Coverage Warning" if english_mode() else "硬膜外覆盖警告",
		"scene": "operating_room",
		"kind": "interaction",
		"prompt": "The planned operative site is outside this epidural coverage. Continuing would leave the operative site without effective analgesia." if english_mode() else "计划手术部位不在本次硬膜外覆盖范围内。继续使用该方案时，术区将没有有效止痛。",
		"speaker": "staff",
		"background_id": "operating_room",
		"actions": [
			{
				"id": "continue_ineffective_epidural",
				"label": "Continue with the epidural" if english_mode() else "仍然使用硬膜外麻醉",
				"response": "“Understood. I will document that the planned operative site is not covered.”" if english_mode() else "「明白。我会记录计划术区没有被这次硬膜外覆盖。」",
				"next": "anesthesia_sensory_test", "requires": [], "flags": ["ineffective_epidural_confirmed"],
				"calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false,
				"response_speaker": "staff", "response_role": "circulating_nurse", "effects": {},
			},
			{
				"id": "switch_epidural_to_local",
				"label": "Switch to local anesthesia" if english_mode() else "改用局部麻醉",
				"response": "“Local anesthesia will cover the planned operative site. I will update the anesthesia record.”" if english_mode() else "「局部麻醉可以覆盖计划术区。我会更新麻醉记录。」",
				"next": "anesthesia_sensory_test", "requires": [],
				"flags": ["local_anesthesia"], "clear_flags": ["epidural_anesthesia", "ineffective_epidural_confirmed"],
				"anesthesia": "局部麻醉", "calm": 0, "minutes": 1, "requires_team": false, "execute_preparation": false,
				"response_speaker": "staff", "response_role": "circulating_nurse", "effects": {},
			},
		],
	}

func surgery_abort_stage() -> Dictionary:
	return runtime_english({
		"id": "surgery_abort",
		"title": "手术中止 · 支援已到场",
		"scene": "operating_room",
		"kind": "surgery_abort",
		"prompt": "当前团队无法继续稳定患者。追加支援到场后，患者情况已经稳定，但原定手术必须中止。",
		"speaker": "narrator",
		"background_id": "operating_room",
		"actions": [],
	})

func or_table_palpation_available() -> bool:
	return current().get("kind", "") == "or_table_palpation" and not procedure_id.is_empty() and not flags.has("or_table_palpation_complete")

func or_table_palpation_profile_id() -> String:
	var surgery := current_surgery()
	var profile_id := str(surgery.get("palpation_profile", surgery.get("diagnosis_reaction_site_group", "generic")))
	return profile_id if palpation_profiles.has(profile_id) else "generic"

func or_table_palpation_relevance(region: String) -> String:
	var profile: Dictionary = palpation_profiles.get(or_table_palpation_profile_id(), {})
	var regions: Dictionary = profile.get("regions", {})
	var relevance := str(regions.get(region, "unrelated"))
	return relevance if relevance in ["primary", "adjacent", "unrelated"] else "unrelated"

func anesthesia_target_regions() -> Array[String]:
	var result: Array[String] = []
	for region in current_surgery().get("anesthesia_target_regions", []):
		result.append(str(region))
	return result

func anesthesia_covered_regions() -> Array[String]:
	if flags.has("general_anesthesia"):
		return ["chest", "abdomen", "breast", "nipple", "genital"]
	if flags.has("local_anesthesia"):
		return anesthesia_target_regions()
	if flags.has("epidural_anesthesia"):
		return ["abdomen", "genital"]
	return []

func anesthesia_region_covered(region: String) -> bool:
	var covered := anesthesia_covered_regions()
	if region == "nipple" and covered.has("breast"):
		return true
	return covered.has(region)

func epidural_effective_for_procedure() -> bool:
	if not flags.has("epidural_anesthesia"):
		return false
	for region in anesthesia_target_regions():
		if not anesthesia_region_covered(region):
			return false
	return not anesthesia_target_regions().is_empty()

func operative_analgesia_effective() -> bool:
	if flags.has("general_anesthesia"):
		return true
	if flags.has("epidural_anesthesia"):
		return epidural_effective_for_procedure()
	if flags.has("local_anesthesia"):
		for region in anesthesia_target_regions():
			if not anesthesia_region_covered(region):
				return false
		return not anesthesia_target_regions().is_empty()
	return false

func operative_without_effective_analgesia() -> bool:
	return flags.has("no_anesthesia_confirmed") or ((flags.has("local_anesthesia") or flags.has("epidural_anesthesia")) and not operative_analgesia_effective())

func patient_awake() -> bool:
	return not flags.has("general_anesthesia") and not flags.has("anesthetized")

func anesthesia_sensory_test_available() -> bool:
	return current().get("kind", "") == "anesthesia_sensory_test" and (flags.has("local_anesthesia") or flags.has("epidural_anesthesia")) and not flags.has("anesthesia_sensory_test_complete")

func or_table_procedure_response(region: String, relevance: String, intensity: String, count: int) -> String:
	if relevance == "unrelated":
		return ""
	var profile: Dictionary = palpation_profiles.get(or_table_palpation_profile_id(), {})
	var reactions: Dictionary = profile.get("reactions", {})
	var region_reactions: Dictionary = reactions.get(region, {})
	var relevance_reactions: Dictionary = region_reactions.get(relevance, {})
	var variants: Array = relevance_reactions.get(intensity, [])
	if variants.is_empty():
		return ""
	var variant: Variant = variants[count % variants.size()]
	return str(variant.get("response", "")) if variant is Dictionary else str(variant)

func or_table_palpation_response(region: String, intensity: String, count: int) -> String:
	if english_mode():
		match region:
			"chest":
				return {
					"light": "“Are you checking my chest there, Doctor?”",
					"standard": "“Mm... I can feel the pressure over my breastbone.”",
					"deep": "“Ah—my chest hurts. Please ease up a little!”",
				}.get(intensity, "“I can feel that over my chest...”")
			"abdomen":
				return {
					"light": "“...It is a little tender there.”",
					"standard": "“Ow... Doctor, it hurts when you press there.”",
					"deep": "“Ah! That hurts—please, be gentler!”",
				}.get(intensity, "“It hurts there...”")
			"breast":
				return "“D-doctor... You are not operating here, are you?”"
			"nipple":
				return "“Ah—ahh... That spot is too sensitive!”"
			"genital":
				return "“It is so embarrassing... but it feels good...”" if count % 2 == 1 else "“Doctor, please do not touch me there...!”"
	match region:
		"chest":
			return {
				"light": "「医生，是在检查胸口这里吗？」",
				"standard": "「唔……胸骨这里能感觉到压迫。」",
				"deep": "「啊、胸口很疼……请轻一点！」",
			}.get(intensity, "「胸口这里能感觉到……」")
		"abdomen":
			return {
				"light": "「……这里有一点疼。」",
				"standard": "「痛……医生，那里按下去很疼。」",
				"deep": "「啊！痛、痛……请轻一点！」",
			}.get(intensity, "「那里会疼……」")
		"breast":
			return "「医、医生……开刀的地方不是这里吧？」"
		"nipple":
			return "「啊、啊啊……那里、那里太敏感了！」"
		"genital":
			return "「好羞耻……可是、好舒服……」" if count % 2 == 1 else "「医生，不要摸那里啊……！」"
	return ""

func apply_or_table_palpation(region: String, intensity: String) -> bool:
	if not or_table_palpation_available() or region not in ["chest", "abdomen", "breast", "nipple", "genital"] or intensity not in ["light", "standard", "deep"]:
		return false
	var intensity_index := ["light", "standard", "deep"].find(intensity)
	var effects := {
		"chest": [
			{"fear": 0, "pain": 0, "dignity": 0, "cooperation": 0},
			{"fear": 0, "pain": 2, "dignity": 0, "cooperation": 0},
			{"fear": 2, "pain": 5, "dignity": 0, "cooperation": -1},
		],
		"abdomen": [
			{"fear": 0, "pain": 1, "dignity": 0, "cooperation": 0},
			{"fear": 1, "pain": 4, "dignity": 0, "cooperation": -1},
			{"fear": 3, "pain": 8, "dignity": 0, "cooperation": -3},
		],
		"breast": [
			{"fear": 1, "pain": 0, "dignity": -4, "cooperation": -1},
			{"fear": 2, "pain": 1, "dignity": -7, "cooperation": -2},
			{"fear": 3, "pain": 2, "dignity": -10, "cooperation": -4},
		],
		"nipple": [
			{"fear": 1, "pain": 1, "dignity": -6, "cooperation": -2},
			{"fear": 2, "pain": 2, "dignity": -10, "cooperation": -4},
			{"fear": 4, "pain": 3, "dignity": -14, "cooperation": -6},
		],
		"genital": [
			{"fear": 2, "pain": 0, "dignity": -8, "cooperation": -3},
			{"fear": 4, "pain": 1, "dignity": -12, "cooperation": -5},
			{"fear": 6, "pain": 2, "dignity": -18, "cooperation": -8},
		],
	}
	var selected: Dictionary = effects[region][intensity_index]
	fear = clampi(fear + int(selected.fear), 0, 100)
	pain = clampi(pain + int(selected.pain), 0, 100)
	dignity = clampi(dignity + int(selected.dignity), 0, 100)
	cooperation_base = clampi(cooperation_base + int(selected.cooperation), 0, 100)
	minutes += 1
	var count := int(or_table_palpation_counts.get(region, 0))
	or_table_palpation_counts[region] = count + 1
	last_palpation_confirmation = ""
	var relevance := or_table_palpation_relevance(region)
	if relevance == "primary" and count == 0:
		sensory_interaction_xp_bonus += 5
	var procedure_response := or_table_procedure_response(region, relevance, intensity, count)
	feedback = procedure_response if not procedure_response.is_empty() else or_table_palpation_response(region, intensity, count)
	if relevance == "primary" and intensity in ["light", "standard"] and not palpation_findings_confirmed.has(region):
		palpation_findings_confirmed.append(region)
		last_palpation_confirmation = region
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	return true

func or_table_needle_response(region: String) -> String:
	if english_mode():
		return {
			"chest": "“Ow! Doctor, why are you using a needle on my chest?”",
			"abdomen": "“Ow! Doctor, what is that needle for?”",
			"breast": "“Ah! Wait—why are you using a needle there?”",
			"nipple": "“Ah—! That spot is far too sensitive!”",
			"genital": "“No... why are you using a needle there too?”",
		}.get(region, "“Ow!”")
	return {
		"chest": "「痛！医生，为什么要拿针刺胸口……！」",
		"abdomen": "「痛！医生，你拿针干什么……！」",
		"breast": "「啊！等一下……为什么要用针啊？」",
		"nipple": "「啊——！那里太敏感了！」",
		"genital": "「不要……那里为什么也要用针……！」",
	}.get(region, "「痛！」")

func apply_or_table_needle(region: String) -> bool:
	if not or_table_palpation_available() or region not in ["chest", "abdomen", "breast", "nipple", "genital"]:
		return false
	var effects := {
		"chest": {"fear": 3, "pain": 5, "dignity": 0, "cooperation": -1},
		"abdomen": {"fear": 3, "pain": 6, "dignity": 0, "cooperation": -2},
		"breast": {"fear": 5, "pain": 6, "dignity": -5, "cooperation": -3},
		"nipple": {"fear": 7, "pain": 8, "dignity": -8, "cooperation": -5},
		"genital": {"fear": 8, "pain": 8, "dignity": -10, "cooperation": -6},
	}
	var selected: Dictionary = effects[region]
	fear = clampi(fear + int(selected.fear), 0, 100)
	pain = clampi(pain + int(selected.pain), 0, 100)
	dignity = clampi(dignity + int(selected.dignity), 0, 100)
	cooperation_base = clampi(cooperation_base + int(selected.cooperation), 0, 100)
	minutes += 1
	or_table_needle_counts[region] = int(or_table_needle_counts.get(region, 0)) + 1
	last_palpation_confirmation = ""
	feedback = or_table_needle_response(region)
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	return true

func anesthesia_test_response(tool: String, region: String, covered: bool) -> String:
	if english_mode():
		if tool == "hand":
			return "“I can feel your hand and the pressure, but it does not hurt.”" if covered else "“I can feel that clearly... it is a little uncomfortable.”"
		return "“I felt the touch, but not a sharp pain.”" if covered else "“Ow! Yes—I can feel the sharp point there!”"
	if tool == "hand":
		return "「能感觉到手和压力，但是不痛。」" if covered else "「这里能很清楚地感觉到……有点不舒服。」"
	return "「能感觉到碰了一下，但没有刺痛。」" if covered else "「痛！这里能感觉到针尖，很清楚！」"

func apply_anesthesia_sensory_test(tool: String, region: String) -> bool:
	if not anesthesia_sensory_test_available() or tool not in ["hand", "needle"] or region not in ["chest", "abdomen", "breast", "nipple", "genital"]:
		return false
	var covered := anesthesia_region_covered(region)
	var key := tool + ":" + region
	var count := int(anesthesia_test_counts.get(key, 0))
	anesthesia_test_counts[key] = count + 1
	minutes += 1
	if tool == "needle" and covered and count == 0:
		sensory_interaction_xp_bonus += 5
	if tool == "hand":
		fear = clampi(fear + (1 if covered else 2), 0, 100)
		if not covered:
			pain = clampi(pain + 1, 0, 100)
	else:
		fear = clampi(fear + (2 if covered else 5), 0, 100)
		pain = clampi(pain + (0 if covered else 7), 0, 100)
		if region in ["breast", "nipple", "genital"]:
			dignity = clampi(dignity - (2 if covered else 5), 0, 100)
			cooperation_base = clampi(cooperation_base - (1 if covered else 3), 0, 100)
	feedback = anesthesia_test_response(tool, region, covered)
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	return true

func apply_anesthesia_test_scalpel(region: String) -> bool:
	if not anesthesia_sensory_test_available() or region not in ["body", "chest", "abdomen", "breast", "nipple", "genital"]:
		return false
	var target_region := anesthesia_target_regions()[0] if region == "body" and not anesthesia_target_regions().is_empty() else region
	var covered := anesthesia_region_covered(str(target_region))
	if covered:
		pain = clampi(pain + 1, 0, 100)
		fear = clampi(fear + 18, 0, 100)
		feedback = "“Why did that suddenly feel cold...? Doctor, what are you doing?”" if english_mode() else "「怎么突然一凉……医生，你在干什么？」"
	else:
		pain = 100
		fear = clampi(fear + 25, 0, 100)
		cooperation_base = clampi(cooperation_base - 8, 0, 100)
		feedback = "“Aaaah—!!”" if english_mode() else "「呀啊啊啊——！！」"
	if not flags.has("anesthesia_test_scalpel_incident"):
		flags.append("anesthesia_test_scalpel_incident")
	if not flags.has("anesthesia_sensory_test_complete"):
		flags.append("anesthesia_sensory_test_complete")
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	stage_id = "anesthesia_test_scalpel_incident"
	return true

func apply_or_table_scalpel(region: String) -> bool:
	if not or_table_palpation_available() or region not in ["body", "chest", "abdomen", "breast", "nipple", "genital"]:
		return false
	pain = 100
	fear = clampi(fear + 25, 0, 100)
	dignity = clampi(dignity - 5, 0, 100)
	cooperation_base = clampi(cooperation_base - 8, 0, 100)
	last_palpation_confirmation = ""
	if not flags.has("premature_incision"):
		flags.append("premature_incision")
	if not flags.has("or_table_scalpel_incident"):
		flags.append("or_table_scalpel_incident")
	if not flags.has("or_table_palpation_complete"):
		flags.append("or_table_palpation_complete")
	feedback = "“Aaaah—!!”" if english_mode() else "「呀啊啊啊——！！」"
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	stage_id = "or_table_scalpel_incident"
	return true

func surgery_in_progress() -> bool:
	return flags.has("surgery_started") and not surgery_success and not surgery_aborted

func surgery_committed() -> bool:
	# Confirming the assembled team commits the patient to the continuous
	# ward-preparation -> operating-room workflow.  The player may still save
	# before the incision, but cannot abandon this case or end the day midway.
	return flags.has("team_confirmed") and not surgery_success and not surgery_aborted

func operative_preparation_stages() -> Array:
	var result: Array = [
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
	return runtime_english(result)

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
	var result: Array = [
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
	return runtime_english(result)

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
	var result: Dictionary = flow[procedure_step_index].duplicate(true)
	if procedure_step_index == 0 and not case_variant_id.is_empty():
		for variant in current_surgery().get("case_variants", []):
			if str(variant.get("id", "")) == case_variant_id and not str(variant.get("player_hint", "")).is_empty():
				result["transition_text"] = str(result.get("transition_text", "")) + "\n" + str(variant.player_hint)
				break
	return result

func surgery_step_display_label() -> String:
	var flow := surgery_flow_steps()
	if procedure_step_index < 0 or procedure_step_index >= flow.size():
		return ""
	var current_step: Dictionary = flow[procedure_step_index]
	if str(current_step.get("stage_kind", "fixed")) == "conditional_correction":
		return "修正" if not english_mode() else "Correction"
	var fixed_index := 0
	for index in range(procedure_step_index + 1):
		if str(flow[index].get("stage_kind", "fixed")) != "conditional_correction":
			fixed_index += 1
	return "%s / %s" % [fixed_index, surgery_fixed_stage_count()]

func current_surgery() -> Dictionary:
	return surgeries.get(procedure_id, {})

func initialize_procedure_state(id: String = procedure_id) -> void:
	var surgery: Dictionary = surgeries.get(id, {})
	procedure_state = surgery.get("initial_state", {}).duplicate(true)
	for metric in ["stability", "blood_loss", "visibility", "progress", "elapsed_time", "stress", "bleeding"]:
		procedure_state[metric] = int(procedure_state.get(metric, 0))
	bleeding = int(procedure_state.get("bleeding", 0))
	minimum_stability_seen = int(procedure_state.get("stability", 100))
	clamp_procedure_state()

func clamp_procedure_state() -> void:
	procedure_state.progress = clampi(int(procedure_state.get("progress", 0)), 0, 100)
	procedure_state.visibility = clampi(int(procedure_state.get("visibility", 0)), 0, 100)
	procedure_state.stability = clampi(int(procedure_state.get("stability", 0)), 0, 100)
	procedure_state.blood_loss = maxi(0, int(procedure_state.get("blood_loss", 0)))
	procedure_state.elapsed_time = maxi(0, int(procedure_state.get("elapsed_time", 0)))
	procedure_state.stress = int(procedure_state.get("stress", 0))
	procedure_state.bleeding = clampi(int(procedure_state.get("bleeding", bleeding)), 0, 100)
	bleeding = int(procedure_state.bleeding)
	minimum_stability_seen = mini(minimum_stability_seen, int(procedure_state.stability))
	lowest_dignity_seen = mini(lowest_dignity_seen, dignity)
	lowest_cooperation_seen = mini(lowest_cooperation_seen, cooperation_base)
	peak_fear_seen = maxi(peak_fear_seen, fear)
	peak_pain_seen = maxi(peak_pain_seen, pain)

func strategic_surgery_active() -> bool:
	for flow_step in surgery_flow_steps():
		for option in flow_step.get("options", []):
			if option.has("strategic_effects") or option.has("conditional_effects"):
				return true
	return false

func apply_surgery_strategic_effects(effects: Dictionary) -> void:
	for metric in ["progress", "elapsed_time", "visibility", "blood_loss", "stability", "bleeding"]:
		if effects.has(metric):
			procedure_state[metric] = int(procedure_state.get(metric, 0)) + int(effects[metric])
	for flag in effects.get("set_flags", []):
		if str(flag) not in surgical_technical_flags:
			surgical_technical_flags.append(str(flag))
	for flag in effects.get("clear_flags", []):
		surgical_technical_flags.erase(str(flag))
	for complication in effects.get("add_complications", []):
		var entry: Dictionary = complication.duplicate(true) if complication is Dictionary else {"id": str(complication), "severity": "minor"}
		if not str(entry.get("id", "")).is_empty():
			surgical_complications.append(entry)
	clamp_procedure_state()

func surgery_condition_met(condition: Dictionary) -> bool:
	if condition.has("any"):
		for child in condition.any:
			if surgery_condition_met(child):
				return true
		return false
	if condition.has("all"):
		for child in condition.all:
			if not surgery_condition_met(child):
				return false
		return true
	var field := str(condition.get("field", condition.get("metric", "")))
	var current_value: Variant = surgical_technical_flags.has(field) if field in ["repair_recheck_required"] else procedure_state.get(field)
	if current_value == null:
		return false
	var target_value: Variant = condition.get("value", 0)
	match str(condition.get("op", condition.get("operator", ""))):
		"lt", "<": return current_value < target_value
		"lte", "<=": return current_value <= target_value
		"gt", ">": return current_value > target_value
		"gte", ">=": return current_value >= target_value
		"eq", "==": return current_value == target_value
		"neq", "!=": return current_value != target_value
	return false

func apply_surgery_option_effects(option: Dictionary) -> Array[Dictionary]:
	apply_surgery_strategic_effects(option.get("strategic_effects", {}))
	var triggered: Array[Dictionary] = []
	for conditional in option.get("conditional_effects", []):
		if surgery_condition_met(conditional.get("when", {})):
			apply_surgery_strategic_effects(conditional.get("strategic_effects", conditional.get("effects", {})))
			triggered.append(conditional)
	return triggered

func surgery_state_summary() -> String:
	if procedure_state.is_empty() or not strategic_surgery_active():
		return ""
	if english_mode():
		return "Progress %s%%  ·  Visibility %s  ·  Bleeding %s  ·  Blood loss %s  ·  Time %s min  ·  Stability %s" % [procedure_state.progress, procedure_state.visibility, procedure_state.bleeding, procedure_state.blood_loss, procedure_state.elapsed_time, procedure_state.stability]
	return "进度 %s%%　·　术野 %s　·　持续出血 %s　·　累计失血 %s　·　用时 %s 分钟　·　稳定 %s" % [procedure_state.progress, procedure_state.visibility, procedure_state.bleeding, procedure_state.blood_loss, procedure_state.elapsed_time, procedure_state.stability]

func pilot_surgery() -> bool:
	return procedure_id in ["surgery_appendix", "surgery_open_cholecystectomy", "surgery_open_inguinal_hernia"]

func surgery_fixed_stage_count() -> int:
	var count := 0
	for step in surgery_flow_steps():
		if str(step.get("stage_kind", "fixed")) != "conditional_correction":
			count += 1
	return count

func surgery_quality_baseline() -> Dictionary:
	return {
		"surgery_appendix": {"expected_time": 60, "expected_blood_loss": 30},
		"surgery_open_cholecystectomy": {"expected_time": 120, "expected_blood_loss": 70},
		"surgery_open_inguinal_hernia": {"expected_time": 90, "expected_blood_loss": 35},
	}.get(procedure_id, {"expected_time": procedure_minutes, "expected_blood_loss": 50})

func surgical_quality_score() -> int:
	if not surgery_success:
		return 0
	var baseline: Dictionary = surgery_quality_baseline()
	var score := 100
	var time_ratio := float(procedure_state.get("elapsed_time", 0)) / maxf(1.0, float(baseline.expected_time))
	if time_ratio > 2.0:
		score -= 25
	elif time_ratio > 1.5:
		score -= 15
	elif time_ratio > 1.25:
		score -= 8
	elif time_ratio > 1.0:
		score -= 4
	var loss_ratio := float(procedure_state.get("blood_loss", 0)) / maxf(1.0, float(baseline.expected_blood_loss))
	if loss_ratio > 4.0:
		score -= 25
	elif loss_ratio > 2.67:
		score -= 15
	elif loss_ratio > 1.67:
		score -= 8
	elif loss_ratio > 1.0:
		score -= 3
	var min_stability := int(minimum_stability_seen)
	if min_stability < 70:
		score -= 25
	elif min_stability < 80:
		score -= 12
	elif min_stability < 90:
		score -= 6
	elif min_stability < 95:
		score -= 2
	for complication in surgical_complications:
		score -= 15 if str(complication.get("severity", "minor")) == "major" else 5
	return clampi(score, 0, 100)

func surgical_quality_grade() -> String:
	if not surgery_success:
		return "F"
	var score := surgical_quality_score()
	if score >= 90:
		return "S"
	if score >= 80:
		return "A"
	if score >= 65:
		return "B"
	return "C"

func pilot_technical_summary() -> Dictionary:
	return {
		"surgical_quality_grade": surgical_quality_grade(),
		"surgical_quality_score": surgical_quality_score(),
		"best_elapsed_time": int(procedure_state.get("elapsed_time", 0)),
		"best_blood_loss": int(procedure_state.get("blood_loss", 0)),
		"minimum_stability_seen": minimum_stability_seen,
		"complications": surgical_complications.duplicate(true),
		"case_variant_id": case_variant_id,
		"surgery_rng_seed": surgery_rng_seed,
		"resolved_random_choices": resolved_random_choices.duplicate(true),
		"lowest_dignity": lowest_dignity_seen,
		"lowest_cooperation": lowest_cooperation_seen,
		"peak_fear": peak_fear_seen,
		"peak_pain": peak_pain_seen,
		"dignity_intrusion_count": dignity_intrusion_count,
		"dignity_break_count": dignity_break_count,
		"cooperation_disruption_count": cooperation_disruption_count,
		"patient_caused_complication_count": patient_caused_complication_count,
	}

func node_physio_stress(flow_step: Dictionary = surgery_flow_step()) -> String:
	var authored := str(flow_step.get("physio_stress", ""))
	if authored in ["low", "medium", "high"]:
		return authored
	var step_id := str(flow_step.get("id", "")).to_lower()
	var cues: Array = flow_step.get("patient_cues", [])
	if procedure_step_index >= surgery_flow_steps().size() - 1 or "closure" in step_id or "close" in step_id:
		return "low"
	if "deep" in step_id or "critical" in step_id or "resection" in step_id or "anastomosis" in step_id or "traction" in cues:
		return "high"
	return "medium"

func anesthesia_crisis_base_risk() -> int:
	# An epidural that misses the operative region uses the same awake,
	# unanalgesed crisis baseline as the explicit no-anesthesia route.
	return 2 if operative_without_effective_analgesia() else 8

func tiered_crisis_modifier(value: int, thresholds: Array, modifiers: Array) -> int:
	for index in thresholds.size():
		if value < int(thresholds[index]):
			return int(modifiers[index])
	return int(modifiers.back())

func physiologic_crisis_chance(flow_step: Dictionary = surgery_flow_step()) -> int:
	if procedure_state.is_empty():
		return 0
	var chance := anesthesia_crisis_base_risk()
	chance += {"low": 0, "medium": 2, "high": 4}.get(node_physio_stress(flow_step), 2)
	# General anesthesia replaces conscious fear/pain risk with its anesthesia base risk.
	if not flags.has("anesthetized"):
		chance += tiered_crisis_modifier(fear, [60, 75, 90], [0, 2, 5, 8])
		chance += tiered_crisis_modifier(pain, [40, 60, 80, 90], [0, 2, 5, 9, 13])
	var stability := int(procedure_state.get("stability", 100))
	chance += 0 if stability >= 80 else 2 if stability >= 60 else 5 if stability >= 40 else 8
	var blood_loss := int(procedure_state.get("blood_loss", 0))
	chance += 0 if blood_loss < 25 else 1 if blood_loss < 50 else 3 if blood_loss < 75 else 6
	return clampi(chance, 2, 30)

func crisis_severity(chance: int) -> String:
	return "severe" if chance >= 20 or int(procedure_state.get("stability", 100)) < 50 or int(procedure_state.get("blood_loss", 0)) >= 75 else "routine"

func crisis_flavor() -> String:
	if flags.has("anesthetized"):
		return "The anesthesia monitor alarms as ventilation and circulation become unstable." if english_mode() else "麻醉监护突然报警：通气与循环指标同时出现明显波动。"
	if operative_without_effective_analgesia():
		return "After the extreme pain, the patient turns pale as her heart rate and blood pressure fall." if english_mode() else "患者在剧痛后脸色骤然发白，心率与血压快速下降。"
	return "The conscious patient's blood pressure falls and the monitor readings become unstable." if english_mode() else "患者仍保持清醒，但血压开始下降，监护数值变得不稳定。"

func crisis_flavor_id_from_roll(roll: int) -> String:
	return str(CRISIS_FLAVOR_IDS[posmod(roll, CRISIS_FLAVOR_IDS.size())])

func crisis_callout_speaker_role_id() -> String:
	for role_id in ["primary_circulating_nurse", "primary_circulating", "circulating_nurse"]:
		var actor_id := str(team.get(role_id, ""))
		if not actor_id.is_empty() and roster.has(actor_id):
			return str(role_id)
	return ""

func crisis_callout_speaker_id() -> String:
	var role_id := crisis_callout_speaker_role_id()
	if not role_id.is_empty():
		return str(team.get(role_id, ""))
	return ""

func select_crisis_callout_variant(actor_id: String, flavor_id: String, roll: int) -> String:
	var person: Dictionary = roster.get(actor_id, {})
	var variants: Array = person.get("crisis_callouts", {}).get(flavor_id, [])
	if variants.is_empty():
		return ""
	var total_weight := 0
	for variant in variants:
		total_weight += maxi(1, int(variant.get("weight", 1)))
	var pick := posmod(floori(roll / float(CRISIS_FLAVOR_IDS.size())), total_weight)
	for variant in variants:
		pick -= maxi(1, int(variant.get("weight", 1)))
		if pick < 0:
			return str(variant.get("id", ""))
	return str(variants.back().get("id", ""))

func crisis_callout_lines(actor_id: String, flavor_id: String, variant_id: String) -> Array:
	var person: Dictionary = roster.get(actor_id, {})
	for variant in person.get("crisis_callouts", {}).get(flavor_id, []):
		if str(variant.get("id", "")) == variant_id:
			return variant.get("attempt_lines", [])
	var generic: Dictionary = GENERIC_CRISIS_CALLOUTS_EN if english_mode() else GENERIC_CRISIS_CALLOUTS_ZH
	return generic.get(flavor_id, generic.get("generic_instability", []))

func crisis_callout_text() -> String:
	if active_crisis.is_empty():
		return ""
	var flavor_id := str(active_crisis.get("flavor_id", "generic_instability"))
	var lines := crisis_callout_lines(str(active_crisis.get("speaker_actor_id", "")), flavor_id, str(active_crisis.get("callout_variant_id", "")))
	if lines.is_empty():
		return ""
	var attempt := clampi(int(active_crisis.get("attempt", 1)), 1, 3)
	return str(lines[mini(attempt - 1, lines.size() - 1)])

func crisis_callout_speaker_name() -> String:
	var actor_id := str(active_crisis.get("speaker_actor_id", ""))
	if not actor_id.is_empty() and roster.has(actor_id):
		return str(roster[actor_id].get("name", actor_id))
	return "Circulating Nurse" if english_mode() else "巡回护士"

func apply_crisis_callout_presentation() -> void:
	last_staff_role = str(active_crisis.get("speaker_role_id", "circulating_nurse"))
	last_staff_id = str(active_crisis.get("speaker_actor_id", ""))
	feedback_speaker = "staff"
	feedback = crisis_callout_text()
	if not last_staff_id.is_empty() and roster.has(last_staff_id):
		feedback = crisis_callout_speaker_name() + "：" + feedback

func maybe_start_physiologic_crisis(roll: int, flow_step: Dictionary) -> bool:
	if roll < 0 or roll > 9999:
		return false
	var chance := physiologic_crisis_chance(flow_step)
	if roll >= chance * 100:
		return false
	var severity := crisis_severity(chance)
	var flavor_id := crisis_flavor_id_from_roll(roll)
	var speaker_role_id := crisis_callout_speaker_role_id()
	var speaker_actor_id := crisis_callout_speaker_id()
	active_crisis = {
		"severity": severity,
		"attempt": 1,
		"chance": chance,
		"source_stage_id": str(flow_step.get("id", "")),
		"flavor_id": flavor_id,
		"speaker_role_id": speaker_role_id,
		"speaker_actor_id": speaker_actor_id,
		"callout_variant_id": select_crisis_callout_variant(speaker_actor_id, flavor_id, roll),
	}
	awaiting_flow_acknowledgement = false
	awaiting_crisis_acknowledgement = false
	apply_crisis_callout_presentation()
	return true

func team_crisis_modifier() -> int:
	var ratings: Array[int] = []
	for role_id in ["assistant_surgeon", "scrub_nurse", "circulating_nurse"]:
		var staff_id := str(team.get(role_id, ""))
		var person: Dictionary = roster.get(staff_id, {})
		if person.is_empty():
			continue
		var skills: Dictionary = person.get("skills", {})
		ratings.append((int(skills.get("surgery", 50)) + int(skills.get("teamwork", 50)) + int(skills.get("calmness", 50))) / 3)
	if ratings.is_empty():
		return 0
	var average := 0
	for rating in ratings:
		average += rating
	average /= ratings.size()
	return 10 if average >= 82 else -3 if average < 55 else 0

func crisis_rescue_chance(option_id: String) -> int:
	if active_crisis.is_empty():
		return 0
	var attempt := clampi(int(active_crisis.get("attempt", 1)), 1, 3)
	var bases: Array = [80, 30, 10] if str(active_crisis.get("severity", "routine")) == "severe" else [90, 50, 25]
	var option_modifier: int = int({"pause_and_stabilize": 0, "hold_field_team_rescue": -8, "finish_critical_action": -25}.get(option_id, -100))
	var team_modifier: int = team_crisis_modifier()
	if option_id == "hold_field_team_rescue":
		team_modifier *= 2
	return clampi(int(bases[attempt - 1]) + int(option_modifier) + team_modifier, 5, 99)

func crisis_rescue_options() -> Array:
	return runtime_english([
		{"id": "pause_and_stabilize", "label": "暂停操作，全力稳定患者", "minutes": 12},
		{"id": "hold_field_team_rescue", "label": "保持当前术野，让团队处理", "minutes": 6},
		{"id": "finish_critical_action", "label": "先完成当前关键动作再处理", "minutes": 2},
	])

func apply_crisis_rescue(option_id: String, roll: int) -> bool:
	if active_crisis.is_empty() or awaiting_crisis_acknowledgement or roll < 0 or roll > 9999:
		return false
	var selected: Dictionary = {}
	for option in crisis_rescue_options():
		if str(option.id) == option_id:
			selected = option
			break
	if selected.is_empty():
		return false
	var chance := crisis_rescue_chance(option_id)
	var attempt := int(active_crisis.get("attempt", 1))
	var success := roll < chance * 100
	var added_minutes := int(selected.minutes)
	minutes += added_minutes
	procedure_extra_minutes += added_minutes
	procedure_state.elapsed_time = int(procedure_state.get("elapsed_time", 0)) + added_minutes
	var record := {"stage_id": active_crisis.source_stage_id, "severity": active_crisis.severity, "attempt": attempt, "option_id": option_id, "chance": chance, "success": success, "flavor_id": active_crisis.get("flavor_id", "generic_instability"), "speaker_role_id": active_crisis.get("speaker_role_id", ""), "speaker_actor_id": active_crisis.get("speaker_actor_id", ""), "callout_variant_id": active_crisis.get("callout_variant_id", "")}
	crisis_history.append(record)
	if success:
		procedure_state.stability = clampi(int(procedure_state.get("stability", 100)) + (18 if option_id == "pause_and_stabilize" else 12), 0, 100)
		active_crisis["resolved"] = true
		awaiting_crisis_acknowledgement = true
		feedback = "“The abnormal readings are under control. The patient is stable; we can continue.”" if english_mode() else "「异常指标控制住了，患者重新稳定，可以继续原定手术。」"
		feedback_speaker = "staff"
		last_staff_role = str(active_crisis.get("speaker_role_id", "circulating_nurse"))
		last_staff_id = str(active_crisis.get("speaker_actor_id", ""))
		if not last_staff_id.is_empty() and roster.has(last_staff_id):
			feedback = str(roster[last_staff_id].name) + "：" + feedback
		clamp_procedure_state()
		return true
	procedure_state.stability = clampi(int(procedure_state.get("stability", 100)) - (12 if str(active_crisis.severity) == "severe" else 8), 0, 100)
	if attempt < 3:
		active_crisis.attempt = attempt + 1
		apply_crisis_callout_presentation()
		clamp_procedure_state()
		return true
	surgery_aborted = true
	if not flags.has("surgery_aborted"):
		flags.append("surgery_aborted")
	active_crisis.clear()
	awaiting_crisis_acknowledgement = false
	procedure_state.stability = maxi(40, int(procedure_state.get("stability", 0)))
	minutes += 20
	procedure_extra_minutes += 20
	procedure_state.elapsed_time = int(procedure_state.get("elapsed_time", 0)) + 20
	feedback = "All three rescue attempts fail to restore safe operating conditions. Additional support stabilizes the patient, and the planned procedure is aborted." if english_mode() else "三次补救均未能让当前团队恢复安全手术条件。追加支援到场后患者已经稳定，原定手术中止。"
	feedback_speaker = "narrator"
	last_staff_id = ""
	last_staff_role = ""
	stage_id = "surgery_abort"
	clamp_procedure_state()
	return true

func acknowledge_crisis_resolution() -> bool:
	if not awaiting_crisis_acknowledgement or active_crisis.is_empty() or not bool(active_crisis.get("resolved", false)):
		return false
	awaiting_crisis_acknowledgement = false
	active_crisis.clear()
	last_staff_id = ""
	last_staff_role = ""
	feedback = ""
	feedback_speaker = "narrator"
	if not resolve_patient_event_for_stage():
		complete_surgery_flow_stage()
	return true

func operative_position() -> String:
	return str(current_surgery().get("positioning", {}).get("primary_position", "supine"))

func refresh_operative_positioning_stage() -> void:
	var stage: Dictionary = stages.get("operative_positioning", {})
	if stage.is_empty():
		return
	var actions: Array = stage.get("actions", [])
	if operative_position() == "lithotomy":
		stage["prompt"] = "团队依据术式改为截石位：患者的双腿同步抬起，屈髋屈膝后分别放入带软垫的腿架；护士确认骶尾部、腓骨头与足跟没有异常受压，再完成对称固定。"
		if not actions.is_empty():
			actions[0]["label"] = "确认腿架与受压点保护，完成截石位固定"
			actions[0]["response"] = "团队同步托起双腿并放入腿架，逐一确认软垫、关节角度与固定带。患者在全身麻醉下没有意识反应。"
	else:
		stage["prompt"] = "团队依据术式调整仰卧体位，在肩、肘、髋与足跟下加软垫保护受压点；双臂与腿部被安置到预定角度，再用安全固定带限制意外移动。"
		if not actions.is_empty():
			actions[0]["label"] = "确认受压点保护，完成仰卧位固定"
			actions[0]["response"] = "团队托住肩、髋与四肢完成仰卧位调整，软垫和安全固定带逐一就位。患者在全身麻醉下没有意识反应。"
	stage["actions"] = actions
	stages["operative_positioning"] = runtime_english(stage)

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

func patient_interaction_runtime_valid(interaction: Dictionary) -> bool:
	var prompt: Variant = interaction.get("prompt")
	var actions: Variant = interaction.get("actions")
	if not prompt is String or str(prompt).strip_edges().is_empty() or not actions is Array:
		return false
	if actions.is_empty() or actions.size() > 3:
		return false
	for action in actions:
		if not action is Dictionary or str(action.get("id", "")).is_empty() or str(action.get("label", "")).is_empty():
			return false
	return true

func patient_interaction_flags_match(interaction: Dictionary) -> bool:
	for required_flag in interaction.get("required_flags", []):
		if not flags.has(required_flag):
			return false
	for excluded_flag in interaction.get("excluded_flags", []):
		if flags.has(excluded_flag):
			return false
	return true

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
				if not interaction is Dictionary or not patient_interaction_runtime_valid(interaction):
					continue
				if not patient_interaction_flags_match(interaction):
					continue
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

func register_temporary_condition_cues(cues: Array) -> void:
	for condition_id in temporary_condition_definitions:
		var definition_entry: Dictionary = temporary_condition_definitions[condition_id]
		if not cues.has(str(definition_entry.trigger_cue)):
			continue
		if active_temporary_conditions.has(condition_id):
			var existing: Dictionary = active_temporary_conditions[condition_id]
			existing.severity = mini(3, int(existing.severity) + 1)
			existing.remaining_steps = maxi(int(existing.remaining_steps), int(definition_entry.remaining_steps))
			active_temporary_conditions[condition_id] = existing
		else:
			active_temporary_conditions[condition_id] = {
				"severity": int(definition_entry.initial_severity),
				"remaining_steps": int(definition_entry.remaining_steps),
			}

func prioritized_temporary_condition_id() -> String:
	var selected_id := ""
	var selected_severity := -1
	var selected_priority := -1
	for condition_id in active_temporary_conditions:
		var condition_state: Dictionary = active_temporary_conditions[condition_id]
		var definition_entry: Dictionary = temporary_condition_definitions.get(condition_id, {})
		if definition_entry.is_empty() or int(condition_state.get("remaining_steps", 0)) <= 0:
			continue
		var severity := int(condition_state.get("severity", 1))
		var priority := int(definition_entry.get("priority", 0))
		if severity > selected_severity or (severity == selected_severity and priority > selected_priority) or (severity == selected_severity and priority == selected_priority and (selected_id.is_empty() or str(condition_id) < selected_id)):
			selected_id = str(condition_id)
			selected_severity = severity
			selected_priority = priority
	return selected_id

func temporary_condition_interaction(condition_id: String) -> Dictionary:
	var definition_entry: Dictionary = temporary_condition_definitions.get(condition_id, {})
	var condition_state: Dictionary = active_temporary_conditions.get(condition_id, {})
	if definition_entry.is_empty() or condition_state.is_empty():
		return {}
	var severity := clampi(int(condition_state.get("severity", 1)), 1, 3)
	var prompt: String = str(definition_entry.get("prompts", {}).get(str(severity), ""))
	var actions: Variant = definition_entry.get("actions", [])
	if prompt.strip_edges().is_empty() or not actions is Array or actions.is_empty():
		return {}
	return {
		"id": "temporary_condition_" + condition_id,
		"prompt": prompt,
		"speaker": "patient",
		"actions": actions.duplicate(true),
	}

func apply_temporary_condition_effect(condition_id: String, effect: Variant) -> void:
	if condition_id.is_empty() or not active_temporary_conditions.has(condition_id) or not effect is Dictionary:
		return
	if bool(effect.get("clear", false)):
		active_temporary_conditions.erase(condition_id)
		return
	var condition_state: Dictionary = active_temporary_conditions[condition_id]
	condition_state.severity = clampi(int(condition_state.severity) + int(effect.get("severity_delta", 0)), 1, 3)
	condition_state.remaining_steps = maxi(0, int(condition_state.remaining_steps) + int(effect.get("remaining_steps_delta", 0)))
	active_temporary_conditions[condition_id] = condition_state

func tick_temporary_conditions() -> void:
	var expired: Array[String] = []
	for condition_id in active_temporary_conditions:
		var condition_state: Dictionary = active_temporary_conditions[condition_id]
		condition_state.remaining_steps = int(condition_state.remaining_steps) - 1
		if int(condition_state.remaining_steps) <= 0:
			expired.append(str(condition_id))
		else:
			active_temporary_conditions[condition_id] = condition_state
	for condition_id in expired:
		active_temporary_conditions.erase(condition_id)

func temporary_condition_status_text() -> String:
	if active_condition_id.is_empty() or not active_temporary_conditions.has(active_condition_id):
		return ""
	var definition_entry: Dictionary = temporary_condition_definitions.get(active_condition_id, {})
	var condition_state: Dictionary = active_temporary_conditions[active_condition_id]
	return "%s · %s级 · 预计持续%s步" % [definition_entry.get("label", active_condition_id), condition_state.severity, condition_state.remaining_steps]

func cached_episode_roll(key: String) -> int:
	if resolved_random_choices.has(key):
		return int(resolved_random_choices[key])
	var roll := posmod(hash("%s:%s" % [surgery_rng_seed, key]), 100)
	resolved_random_choices[key] = roll
	return roll

func resolve_patient_intrusion_for_stage(flow_step: Dictionary) -> bool:
	if flags.has("anesthetized") or patient_event_consumed_this_stage:
		return false
	var stage_key := str(flow_step.get("id", procedure_step_index))
	var cues: Array = flow_step.get("patient_cues", [])
	var cooperation := cooperation_value()
	var intrusion_kind := ""
	if dignity <= 10 and (cues.has("exposure") or cues.has("deep_manipulation")) and cached_episode_roll("patient_intrusion:%s:dignity_break" % stage_key) < 25:
		intrusion_kind = "dignity_break"
	elif cooperation <= 35 and (cues.has("traction") or cues.has("deep_manipulation")) and cached_episode_roll("patient_intrusion:%s:cooperation_disruption" % stage_key) < 30:
		intrusion_kind = "cooperation_disruption"
	elif dignity <= 40 and (cues.has("exposure") or cues.has("pressure")) and cached_episode_roll("patient_intrusion:%s:dignity_intrusion" % stage_key) < 25:
		intrusion_kind = "dignity_intrusion"
	if intrusion_kind.is_empty():
		return false
	patient_event_consumed_this_stage = true
	last_intrusion_stage_index = procedure_step_index
	patient_intrusion_history.append("%s:%s" % [stage_key, intrusion_kind])
	patient_event_count += 1
	match intrusion_kind:
		"dignity_break":
			dignity_break_count += 1
			active_patient_interaction = {
				"id": "intrusion_dignity_break_%s" % stage_key,
				"prompt": "「等一下……我不想再继续了。至少先告诉我接下来要做什么。」",
				"actions": [
					{"id": "intrusion_break_explain", "label": "暂停并向患者说明下一步", "response": "「好……这样我能配合。」", "response_speaker": "patient", "minutes": 2, "effects": {"dignity": 6, "cooperation": 8, "fear": -3, "pain": 0}},
					{"id": "intrusion_break_continue", "label": "要求患者继续配合", "response": "「……我会尽量不动。」", "response_speaker": "patient", "minutes": 0, "effects": {"dignity": -4, "cooperation": -12, "fear": 6, "pain": 2}},
				]
			}
		"cooperation_disruption":
			cooperation_disruption_count += 1
			active_patient_interaction = {
				"id": "intrusion_cooperation_%s" % stage_key,
				"prompt": "「我有点撑不住了……能不能先停一下？」",
				"actions": [
					{"id": "intrusion_cooperation_stabilize", "label": "先稳定患者，再继续操作", "response": "「好，我会尽量保持不动。」", "response_speaker": "patient", "minutes": 2, "effects": {"cooperation": 10, "fear": -4, "pain": -2, "dignity": 0}},
					{"id": "intrusion_cooperation_continue", "label": "维持当前操作，要求患者继续", "response": "「……我知道了。」", "response_speaker": "patient", "minutes": 0, "effects": {"cooperation": -8, "fear": 4, "pain": 4, "dignity": -2}},
				]
			}
		"dignity_intrusion":
			dignity_intrusion_count += 1
			active_patient_interaction = {
				"id": "intrusion_dignity_%s" % stage_key,
				"prompt": "「……这样暴露着，我还是有点不舒服。」",
				"actions": [
					{"id": "intrusion_dignity_acknowledge", "label": "确认必要范围，并尽快继续", "response": "「嗯……知道了。」", "response_speaker": "patient", "minutes": 0, "effects": {"dignity": 5, "cooperation": 3, "fear": -2, "pain": 0}},
					{"id": "intrusion_dignity_dismiss", "label": "不作解释，直接继续", "response": "「……」", "response_speaker": "patient", "minutes": 0, "effects": {"dignity": -8, "cooperation": -3, "fear": 5, "pain": 0}},
				]
			}
	feedback = str(active_patient_interaction.prompt)
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	awaiting_patient_choice = true
	return true

func resolve_patient_event_for_stage() -> bool:
	active_patient_interaction.clear()
	active_condition_id = ""
	awaiting_patient_choice = false
	if patient_event_consumed_this_stage:
		return false
	if flags.has("anesthetized"):
		return false
	var flow_step: Dictionary = surgery_flow_step()
	if flow_step.is_empty():
		return false
	if resolve_patient_intrusion_for_stage(flow_step):
		return true
	if temporary_conditions_enabled:
		register_temporary_condition_cues(flow_step.get("patient_cues", []))
	var condition_id := prioritized_temporary_condition_id() if temporary_conditions_enabled else ""
	if not condition_id.is_empty():
		var condition_interaction := temporary_condition_interaction(condition_id)
		if not condition_interaction.is_empty():
			active_condition_id = condition_id
			active_patient_interaction = condition_interaction
			patient_event_count += 1
			patient_event_consumed_this_stage = true
			awaiting_patient_choice = true
			var condition_state: Dictionary = active_temporary_conditions[condition_id]
			var condition_reaction_id := "temporary_condition_%s_%s" % [condition_id, condition_state.severity]
			feedback = patient_reaction(condition_reaction_id, str(condition_interaction.prompt))
			feedback_speaker = "patient"
			last_staff_id = ""
			last_staff_role = ""
			return true
	var theme: String = str(flow_step.get("awake_interlude", ""))
	if theme.is_empty():
		return false
	var interaction := match_patient_interaction(theme, flow_step.get("patient_cues", []), dominant_patient_state())
	if interaction.is_empty():
		return false
	active_patient_interaction = interaction.duplicate(true)
	patient_interaction_history.append(str(interaction.id))
	patient_event_consumed_this_stage = true
	patient_event_count += 1
	awaiting_patient_choice = true
	feedback = str(interaction.prompt)
	feedback_speaker = "patient"
	last_staff_id = ""
	last_staff_role = ""
	return true

func complete_surgery_flow_stage() -> void:
	tick_temporary_conditions()
	var completed_step := surgery_flow_step()
	if not completed_step.is_empty():
		var completed_stage_id := str(completed_step.get("id", ""))
		if str(completed_step.get("stage_kind", "fixed")) == "conditional_correction":
			conditional_stage_resolution[completed_stage_id] = "completed"
		var progress_delta := int(completed_step.get("progress_delta", 0))
		if progress_delta != 0:
			apply_surgery_strategic_effects({"progress": progress_delta})
	procedure_step_index += 1
	var flow := surgery_flow_steps()
	while procedure_step_index < flow.size():
		var next_step: Dictionary = flow[procedure_step_index]
		if str(next_step.get("stage_kind", "fixed")) != "conditional_correction":
			break
		var correction_id := str(next_step.get("id", ""))
		var resolution := str(conditional_stage_resolution.get(correction_id, ""))
		if resolution in ["skipped", "completed"]:
			procedure_step_index += 1
			continue
		if not surgery_condition_met(next_step.get("entry_condition", {})):
			conditional_stage_resolution[correction_id] = "skipped"
			procedure_step_index += 1
			continue
		conditional_stage_resolution[correction_id] = "entered"
		break
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
	active_condition_id = ""
	patient_event_consumed_this_stage = false
	awaiting_patient_choice = false
	awaiting_patient_acknowledgement = false
	last_staff_id = ""
	last_staff_role = ""
	feedback = ""
	feedback_speaker = "narrator"

func duration_text(value: int) -> String:
	if english_mode():
		if value % 60 == 0:
			return "%s hr" % (value / 60)
		if value > 60:
			return "%s hr %s min" % [value / 60, value % 60]
		return "%s min" % value
	if value % 60 == 0:
		return "%s小时" % (value / 60)
	if value > 60:
		return "%s小时%s分钟" % [value / 60, value % 60]
	return "%s分钟" % value

func procedure_total_minutes() -> int:
	return procedure_minutes + procedure_extra_minutes

func surgery_settlement_total_minutes() -> int:
	return procedure_total_minutes() + POSTOPERATIVE_WRAP_UP_MINUTES

func presence_phase_for_stage(stage: String = stage_id) -> String:
	var operative_stages := [
		"general_induction", "surgery_start_general", "surgery_start_epidural",
		"surgery_start_local", "surgery_start_none", "instrument_handoff",
		"assistant_ready", "incision_ready", "general_operation", "operative_contact",
		"ongoing_interaction", "closure_interaction", "procedure_flow",
		"procedure_execute", "surgery_result",
	]
	return "or" if stage in operative_stages else "preop"

func apply_presence_delta(delta: int, phase: String) -> int:
	if delta == 0:
		return 0
	var limit := int(Progression.PRESENCE_PHASE_CLAMPS.get(phase, 1))
	var raw_before := presence_or_raw if phase == "or" else presence_preop_raw
	var contribution_before := clampi(raw_before, -limit, limit)
	var raw_after := raw_before + delta
	var contribution_after := clampi(raw_after, -limit, limit)
	if phase == "or":
		presence_or_raw = raw_after
	else:
		presence_preop_raw = raw_after
	var applied := contribution_after - contribution_before
	player_effects.presence = int(player_effects.get("presence", 0)) + applied
	return applied

func surgery_completion_text() -> String:
	if english_mode():
		if procedure_extra_minutes <= 0:
			return "%s was completed successfully in %s. %s is %s." % [procedure_name, duration_text(procedure_minutes), patient_name, postoperative_state_text()]
		return "%s required %s plus %s for intraoperative management (%s total). The operation was completed successfully, and %s is %s." % [procedure_name, duration_text(procedure_minutes), duration_text(procedure_extra_minutes), duration_text(procedure_total_minutes()), patient_name, postoperative_state_text()]
	if procedure_extra_minutes <= 0:
		return "%s历时%s，顺利完成。患者%s的状态%s。" % [procedure_name, duration_text(procedure_minutes), patient_name, postoperative_state_text()]
	return "%s手术操作%s；术中应对额外%s，总计%s。手术顺利完成，患者%s的状态%s。" % [procedure_name, duration_text(procedure_minutes), duration_text(procedure_extra_minutes), duration_text(procedure_total_minutes()), patient_name, postoperative_state_text()]

func team_ready() -> bool:
	var used: Array = []
	for role in definition.roles:
		var id: String = team.get(role.id, "")
		if not qualified(id, role) or used.has(id):
			return false
		used.append(id)
	return true

func sweep_team_ready() -> bool:
	if not team_ready():
		return false
	var ward_role: Dictionary = definition.ward_role
	var ward_id := str(team.get(str(ward_role.id), ""))
	if not qualified(ward_id, ward_role):
		return false
	for role in definition.roles:
		if str(team.get(str(role.id), "")) == ward_id:
			return false
	return true

func action_reason(action: Dictionary) -> String:
	if not action_visible(action):
		return "This option is currently unavailable." if english_mode() else "这项选择当前不可用"
	if done.has(action.id):
		return "Completed." if english_mode() else "已完成"
	for required in action.requires:
		if not flags.has(required):
			return "Complete the preceding preparation first." if english_mode() else "请先完成前面的准备"
	if action.requires_team and not team_ready():
		return "Assign three different team members first." if english_mode() else "请选齐三个不同的团队成员"
	if action.get("requires_ward_nurse", false) and not team.has(definition.ward_role.id):
		return "Assign a ward-preparation nurse first." if english_mode() else "请先指派病房准备护士"
	if action.execute_preparation and not team.has(definition.ward_role.id):
		return "Assign a ward-preparation nurse." if english_mode() else "请指派病房准备护士"
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
		"graphic_preop_next":
			if event.size() != 1 or stage_id != "graphic_preop_dialogue" or graphic_preop_nodes.is_empty():
				return false
			if graphic_preop_node_index + 1 >= graphic_preop_nodes.size():
				complete_graphic_preop_dialogue()
			else:
				graphic_preop_node_index += 1
				show_graphic_preop_node()
		"legacy_disable_temporary_conditions":
			if event.size() != 1 or not events.is_empty():
				return false
			temporary_conditions_enabled = false
		"procedure":
			var procedure_event_keys := ["kind", "id", "palpation_cg_id", "surgery_rng_seed", "case_variant_id"]
			if event.keys().any(func(key: Variant): return str(key) not in procedure_event_keys) or not event.get("id") is String or (event.has("palpation_cg_id") and (not event.get("palpation_cg_id") is String or str(event.palpation_cg_id) not in OR_TABLE_PALPATION_CG_IDS)) or (event.has("surgery_rng_seed") and not (event.get("surgery_rng_seed") is int or event.get("surgery_rng_seed") is float)) or (event.has("case_variant_id") and not event.get("case_variant_id") is String) or current().kind != "surgery_select" or not procedure_id.is_empty():
				return false
			if not surgeries.has(event.id):
				return false
			if not procedure_unlocked(str(event.id)):
				last_error = procedure_lock_reason(str(event.id))
				return false
			var surgery: Dictionary = surgeries[event.id]
			last_staff_id = ""
			last_staff_role = ""
			procedure_id = surgery.id
			or_table_palpation_cg_id = str(event.get("palpation_cg_id", OR_TABLE_PALPATION_CG_IDS[0]))
			or_table_palpation_counts.clear()
			or_table_needle_counts.clear()
			anesthesia_test_counts.clear()
			sensory_interaction_xp_bonus = 0
			palpation_findings_confirmed.clear()
			last_palpation_confirmation = ""
			procedure_name = surgery.name
			procedure_minutes = int(surgery.duration_minutes)
			var authored_seed := int(event.get("surgery_rng_seed", 0))
			surgery_rng_seed = authored_seed if authored_seed != 0 else absi(hash("%s:%s:%s" % [definition.get("id", ""), surgery.id, definition.get("patient_id", "")]))
			case_variant_id = str(event.get("case_variant_id", ""))
			resolved_random_choices.clear()
			if case_variant_id.is_empty():
				var variants: Array = surgery.get("case_variants", [])
				if not variants.is_empty():
					var roll := posmod(surgery_rng_seed, 100)
					var cursor := 0
					for variant in variants:
						cursor += int(variant.get("weight", 0))
						if roll < cursor:
							case_variant_id = str(variant.get("id", "standard"))
							break
					if case_variant_id.is_empty():
						case_variant_id = str(variants.back().get("id", "standard"))
			resolved_random_choices["case_variant"] = case_variant_id
			if not event.has("surgery_rng_seed"):
				event["surgery_rng_seed"] = surgery_rng_seed
			if not event.has("case_variant_id"):
				event["case_variant_id"] = case_variant_id
			refresh_operative_positioning_stage()
			procedure_extra_minutes = 0
			initialize_procedure_state(str(surgery.id))
			if not case_variant_id.is_empty():
				for variant in surgery.get("case_variants", []):
					if str(variant.get("id", "")) == case_variant_id:
						procedure_state["visibility"] = int(variant.get("initial_visibility", procedure_state.get("visibility", 0)))
						break
			clamp_procedure_state()
			procedure_step_index = 0
			procedure_step_history.clear()
			procedure_corrections = 0
			flags.erase("quick_surgery")
			surgical_complications.clear()
			surgical_technical_flags.clear()
			conditional_stage_resolution.clear()
			patient_intrusion_history.clear()
			patient_event_consumed_this_stage = false
			last_intrusion_stage_index = -1
			cooperation_disruption_count = 0
			lowest_dignity_seen = dignity
			lowest_cooperation_seen = cooperation_base
			peak_fear_seen = fear
			peak_pain_seen = pain
			dignity_intrusion_count = 0
			dignity_break_count = 0
			patient_caused_complication_count = 0
			surgery_aborted = false
			active_crisis.clear()
			awaiting_crisis_acknowledgement = false
			crisis_history.clear()
			awaiting_flow_acknowledgement = false
			awaiting_patient_choice = false
			awaiting_patient_acknowledgement = false
			active_patient_interaction.clear()
			patient_interaction_history.clear()
			patient_event_count = 0
			active_temporary_conditions.clear()
			active_condition_id = ""
			pending_flow_stage_id = ""
			pending_flow_retry = false
			procedure_mismatch = procedure_id != str(definition.surgery_id)
			if procedure_mismatch:
				flags.append("wrong_procedure_selected")
				fear = clampi(fear + 40, 0, 100)
				var mismatch_fallback := "“N-no, doctor! That is not where my operation is supposed to be...!”" if english_mode() else "「不、不是吧，医生？我不是要做那里……！」"
				feedback = patient_reaction("procedure_mismatch", mismatch_fallback)
				feedback_speaker = "patient"
				stage_id = "procedure_mismatch"
			else:
				feedback = ("Procedure confirmed: %s. Complete operating-table palpation before selecting anesthesia." if english_mode() else "已确认本次术式：%s。请先完成手术台触诊，再选择麻醉方案。") % procedure_name
				feedback_speaker = "narrator"
				stage_id = "or_table_palpation"
		"or_table_palpation":
			if event.size() != 3 or not event.get("region") is String or not event.get("intensity") is String:
				return false
			if not apply_or_table_palpation(str(event.region), str(event.intensity)):
				return false
		"or_table_needle":
			if event.size() != 2 or not event.get("region") is String:
				return false
			if not apply_or_table_needle(str(event.region)):
				return false
		"or_table_scalpel":
			if event.size() != 2 or not event.get("region") is String:
				return false
			if not apply_or_table_scalpel(str(event.region)):
				return false
		"or_table_palpation_complete":
			if event.size() != 1 or not or_table_palpation_available():
				return false
			flags.append("or_table_palpation_complete")
			feedback = "Palpation complete. Select the anesthesia plan." if english_mode() else "触诊完成。接下来选择麻醉方案。"
			feedback_speaker = "narrator"
			stage_id = "ready"
		"anesthesia_sensory_test":
			if event.size() != 3 or not event.get("tool") is String or not event.get("region") is String:
				return false
			if not apply_anesthesia_sensory_test(str(event.tool), str(event.region)):
				return false
		"anesthesia_test_scalpel":
			if event.size() != 2 or not event.get("region") is String:
				return false
			if not apply_anesthesia_test_scalpel(str(event.region)):
				return false
		"anesthesia_sensory_test_complete":
			if event.size() != 1 or not anesthesia_sensory_test_available():
				return false
			flags.append("anesthesia_sensory_test_complete")
			feedback = "Sensory testing skipped or completed. Continue operative preparation." if english_mode() else "麻醉感觉测试已跳过或完成。继续术前准备。"
			feedback_speaker = "narrator"
			stage_id = "operative_positioning"
		"sweep":
			var sweep_stage := str(current().get("kind", ""))
			if event.size() != 2 or not event.get("id") is String or sweep_stage not in ["preparation", "surgery_select"] or not procedure_id.is_empty():
				return false
			if sweep_stage == "preparation" and not sweep_team_ready():
				last_error = "请先选齐手术团队与病房准备护士。"
				return false
			if not surgeries.has(event.id) or str(event.id) != str(definition.surgery_id) or not procedure_unlocked(str(event.id)):
				return false
			var surgery: Dictionary = surgeries[event.id]
			procedure_id = surgery.id
			procedure_name = surgery.name
			procedure_minutes = int(surgery.duration_minutes)
			procedure_extra_minutes = 0
			initialize_procedure_state(str(surgery.id))
			procedure_step_index = 0
			procedure_step_history.clear()
			procedure_corrections = 0
			if not flags.has("quick_surgery"):
				flags.append("quick_surgery")
			procedure_mismatch = false
			minutes += procedure_minutes + POSTOPERATIVE_WRAP_UP_MINUTES
			surgery_success = true
			if not flags.has("surgery_success"):
				flags.append("surgery_success")
			if not flags.has("postoperative_wrap_up_complete"):
				flags.append("postoperative_wrap_up_complete")
			feedback = ("Sweep completed: %s." if english_mode() else "已按熟练流程完成%s。") % procedure_name
			feedback_speaker = "narrator"
			stage_id = definition.completion
		"legacy_surgery_bridge":
			if event.size() != 1 or current().kind != "surgery_flow" or flags.has("legacy_patient_interactions_complete"):
				return false
			flags.append("legacy_patient_interactions_complete")
			if not flags.has("interaction_complete"):
				flags.append("interaction_complete")
			feedback = "The patient interaction from this legacy save is complete. Continue the operation." if english_mode() else "旧版存档中的患者互动已经完成，继续术式流程。"
			feedback_speaker = "narrator"
		"surgery_step":
			if event.size() not in [2, 3] or not event.get("id") is String or (event.has("crisis_roll") and not event.get("crisis_roll") is int) or current().kind != "surgery_flow" or awaiting_flow_acknowledgement or awaiting_patient_choice or awaiting_patient_acknowledgement or not active_crisis.is_empty():
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
			var triggered_conditionals: Array[Dictionary] = []
			if was_correct:
				triggered_conditionals = apply_surgery_option_effects(selected_option)
				var response_lines: Array[String] = []
				var authored_response := str(selected_option.response)
				response_lines.append(authored_response if selected_option.has("strategic_effects") or selected_option.has("conditional_effects") else intraoperative_response(last_staff_id, str(selected_option.id), authored_response, false))
				for conditional in triggered_conditionals:
					var conditional_response := str(conditional.get("response", ""))
					if not conditional_response.is_empty():
						response_lines.append(conditional_response)
				feedback = roster[last_staff_id].name + "：" + "\n".join(response_lines)
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
			if was_correct and event.has("crisis_roll"):
				maybe_start_physiologic_crisis(int(event.crisis_roll), flow_step)
		"crisis_rescue":
			if event.size() != 3 or not event.get("id") is String or not event.get("roll") is int or current().kind != "surgery_flow":
				return false
			if not apply_crisis_rescue(str(event.id), int(event.roll)):
				return false
		"crisis_acknowledge":
			if event.size() != 1 or current().kind != "surgery_flow" or not acknowledge_crisis_resolution():
				return false
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
			if selected_action.is_empty():
				return false
			var delegate_role := str(selected_action.get("delegate_role", ""))
			if not delegate_role.is_empty() and (not team.has(delegate_role) or not roster.has(str(team[delegate_role]))):
				return false
			var interaction_minutes := int(selected_action.minutes)
			minutes += interaction_minutes
			procedure_extra_minutes += interaction_minutes
			var interaction_effects: Dictionary = selected_action.get("effects", {})
			var patient_applied_presence := apply_presence_delta(int(selected_action.get("presence_delta", 0)), "or")
			if patient_applied_presence != 0:
				player_effect_history.append({"id": selected_action.id, "label": selected_action.label, "effects": {"presence": patient_applied_presence}})
			fear = clampi(fear + int(interaction_effects.get("fear", 0)), 0, 100)
			pain = clampi(pain + int(interaction_effects.get("pain", 0)), 0, 100)
			dignity = clampi(dignity + int(interaction_effects.get("dignity", 0)), 0, 100)
			cooperation_base = clampi(cooperation_base + int(interaction_effects.get("cooperation", 0)), 0, 100)
			apply_temporary_condition_effect(active_condition_id, selected_action.get("condition_effect"))
			feedback = str(selected_action.response)
			feedback_speaker = str(selected_action.response_speaker)
			last_staff_id = ""
			last_staff_role = ""
			if not delegate_role.is_empty():
				last_staff_role = delegate_role
				last_staff_id = str(team[delegate_role])
				feedback = roster[last_staff_id].name + "：" + feedback
				feedback_speaker = "staff"
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
				active_condition_id = ""
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
			# Event-sourced saves created before the palpation prototype proceed
			# directly from procedure selection to an anesthesia action. During replay,
			# silently mark the newly inserted stage complete so those saves remain
			# loadable. The live UI never exposes anesthesia actions on this screen.
			if current().get("kind", "") == "or_table_palpation" and str(event.id) in ["choose_general", "choose_epidural", "choose_local", "choose_none"]:
				if not flags.has("or_table_palpation_complete"):
					flags.append("or_table_palpation_complete")
				stage_id = "ready"
			# Saves from builds before the optional sensory-test stage may replay the
			# first preparation action immediately after choosing local or epidural.
			if current().get("kind", "") == "anesthesia_sensory_test" and str(event.id) == "operative_positioning":
				if not flags.has("anesthesia_sensory_test_complete"):
					flags.append("anesthesia_sensory_test_complete")
				stage_id = "operative_positioning"
			if stage_id == "ineffective_epidural_warning" and str(event.id) == "operative_positioning":
				if not flags.has("ineffective_epidural_confirmed"):
					flags.append("ineffective_epidural_confirmed")
				if not flags.has("anesthesia_sensory_test_complete"):
					flags.append("anesthesia_sensory_test_complete")
				stage_id = "operative_positioning"
			var action := {}
			var action_presence_phase := presence_phase_for_stage()
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
			if current().kind == "surgery_execute" and action.id == "execute_confirmed_procedure" and strategic_surgery_active() and not surgery_condition_met(current_surgery().get("success_condition", {})):
				last_error = "术式关键步骤尚未完成。"
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
				or_table_palpation_cg_id = OR_TABLE_PALPATION_CG_IDS[0]
				or_table_palpation_counts.clear()
				or_table_needle_counts.clear()
				anesthesia_test_counts.clear()
				sensory_interaction_xp_bonus = 0
				palpation_findings_confirmed.clear()
				last_palpation_confirmation = ""
				procedure_name = ""
				procedure_minutes = 0
				procedure_extra_minutes = 0
				procedure_mismatch = false
				procedure_step_index = 0
				procedure_step_history.clear()
				procedure_corrections = 0
				surgery_aborted = false
				active_crisis.clear()
				awaiting_crisis_acknowledgement = false
				crisis_history.clear()
				procedure_state.clear()
				bleeding = 0
				minimum_stability_seen = 100
				surgical_complications.clear()
				surgical_technical_flags.clear()
				surgery_rng_seed = 0
				case_variant_id = ""
				resolved_random_choices.clear()
				conditional_stage_resolution.clear()
				patient_event_consumed_this_stage = false
				last_intrusion_stage_index = -1
				cooperation_disruption_count = 0
				patient_intrusion_history.clear()
				lowest_dignity_seen = 100
				lowest_cooperation_seen = 100
				peak_fear_seen = 0
				peak_pain_seen = 0
				dignity_intrusion_count = 0
				dignity_break_count = 0
				patient_caused_complication_count = 0
				awaiting_flow_acknowledgement = false
				awaiting_patient_choice = false
				awaiting_patient_acknowledgement = false
				active_patient_interaction.clear()
				patient_interaction_history.clear()
				patient_event_count = 0
				active_temporary_conditions.clear()
				active_condition_id = ""
				pending_flow_stage_id = ""
				pending_flow_retry = false
			var profile_effects: Dictionary = action.get("player_effects", {})
			if not profile_effects.is_empty():
				for metric in player_effects:
					if metric == "presence":
						continue
					player_effects[metric] = int(player_effects[metric]) + int(profile_effects.get(metric, 0))
				var recorded_profile_effects := profile_effects.duplicate(true)
				recorded_profile_effects.erase("presence")
				if not recorded_profile_effects.is_empty():
					player_effect_history.append({"id": action.id, "label": action.label, "effects": recorded_profile_effects})
			var action_applied_presence := apply_presence_delta(int(profile_effects.get("presence", 0)) + int(action.get("presence_delta", 0)), action_presence_phase)
			if action_applied_presence != 0:
				player_effect_history.append({"id": action.id, "label": action.label, "effects": {"presence": action_applied_presence}})
			if action.has("anesthesia"):
				anesthesia = str(action.anesthesia)
			var effects: Dictionary = action.get("effects", {})
			fear = clampi(fear + int(effects.get("fear", 0)), 0, 100)
			pain = clampi(pain + int(effects.get("pain", 0)), 0, 100)
			dignity = clampi(dignity + int(effects.get("dignity", 0)), 0, 100)
			cooperation_base = clampi(cooperation_base + int(effects.get("cooperation", 0)), 0, 100)
			feedback = patient_reaction(str(action.id), str(action.response))
			feedback_speaker = str(action.response_speaker)
			if action.id == "incise_epidural" and not operative_analgesia_effective():
				# The epidural still affects its authored lower-body regions, but the
				# planned breast/thoracic incision has no analgesic coverage.
				fear = clampi(fear + 22, 0, 100)
				pain = clampi(pain + 72, 0, 100)
				dignity = clampi(dignity - 25, 0, 100)
				cooperation_base = clampi(cooperation_base - 30, 0, 100)
				feedback = patient_reaction("incise_none", "“Ah—stop! I can feel the incision! It hurts!”" if english_mode() else "「啊——停下！我能感觉到刀切进去了，好痛！」")
				feedback_speaker = "patient"
			var preparation_reaction_id := operative_preparation_reaction_id(str(action.id))
			if not preparation_reaction_id.is_empty():
				feedback = patient_reaction(preparation_reaction_id, operative_preparation_fallback(str(action.id)))
				feedback_speaker = "patient"
			if current().kind == "surgery_execute" and action.id == "execute_confirmed_procedure":
				minutes += procedure_minutes + POSTOPERATIVE_WRAP_UP_MINUTES
				surgery_success = true
				flags.append("surgery_success")
				flags.append("postoperative_wrap_up_complete")
				feedback = surgery_completion_text()
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
				var stabilization_reaction_id := "assistant_stabilize_none" if operative_without_effective_analgesia() else "assistant_stabilize_local" if flags.has("local_anesthesia") else "assistant_stabilize_epidural"
				var stabilization_fallback := "“Do not press there—it hurts! I will try not to move, but please do not use sudden force...!”" if english_mode() and stabilization_reaction_id.ends_with("none") else "“I can feel you holding that area steady... Please tell me before the incision.”" if english_mode() else "「别按那里——很痛！我会努力不动，可是请不要突然用力……！」" if stabilization_reaction_id.ends_with("none") else "「我感觉到你们固定住那里了……请告诉我什么时候会下刀。」"
				feedback += "\n%s：%s" % [patient_name, patient_reaction(stabilization_reaction_id, stabilization_fallback)]
			if action.next != null:
				var action_next: String = str(action.next)
				if action.id == "acknowledge_procedure_mismatch":
					action_next = "or_table_palpation"
				if action.id == "begin_manual_ward_preparation":
					action_next = "ward_enema"
				if action.id in ["induction_reassure", "induction_brief", "insist_without_anesthesia"]:
					action_next = "operative_positioning"
				elif action.id == "choose_local":
					action_next = "anesthesia_sensory_test"
				elif action.id == "choose_epidural":
					action_next = "anesthesia_sensory_test" if epidural_effective_for_procedure() else "ineffective_epidural_warning"
				stage_id = action_next
				if action.id == "graphic_answer":
					var graphic_config: Dictionary = definition.get("graphic_preop", {})
					var graphic_family: Dictionary = graphic_config.get("families", {}).get(graphic_preop_family(), {})
					fear = clampi(fear + int(graphic_family.get("fear_delta", 20)), 0, 100)
					dignity = clampi(dignity + int(graphic_family.get("dignity_delta", -5)), 0, 100)
					if not initialize_graphic_preop_dialogue():
						complete_graphic_preop_dialogue()
				if current().kind == "surgery_flow" and not feedback.is_empty():
					awaiting_patient_acknowledgement = true
		_:
			return false
	events.append(event.duplicate(true))
	last_error = ""
	return true

func staff_has_low_surgery_proficiency(staff_id: String) -> bool:
	return str(roster.get(staff_id, {}).get("surgery_proficiency", "trained")) in ["novice", "limited"]

func active_procedure_group() -> String:
	var surgery_id := procedure_id if not procedure_id.is_empty() else str(definition.get("surgery_id", ""))
	return str(surgeries.get(surgery_id, {}).get("procedure_group", ""))

func procedure_group_team_dialogue(staff_id: String, dialogue_key: String) -> String:
	var profiles: Variant = roster.get(staff_id, {}).get("procedure_group_team_dialogue", {})
	if not profiles is Dictionary:
		return ""
	var group_id := active_procedure_group()
	var profile: Variant = profiles.get(group_id, profiles.get("default", {}))
	if not profile is Dictionary:
		return ""
	return str(profile.get(dialogue_key, ""))

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
	var scoped_dialogue_key := "intraoperative_correction" if correction else "intraoperative"
	var scoped_response := procedure_group_team_dialogue(staff_id, scoped_dialogue_key)
	if not scoped_response.is_empty():
		return scoped_response
	if not staff_has_low_surgery_proficiency(staff_id):
		return authored
	if str(roster.get(staff_id, {}).get("profession", "")) == "nurse":
		var nurse_fallback := "“I am not certain about this step. Please verify it again, Dr. Sakaguchi.”" if english_mode() and correction else "“I am still learning this operating-room workflow. The step is complete, but please verify it.”" if english_mode() else "「我不敢确定这一步，请坂口医生再核对一次。」" if correction else "「我对手术室流程不熟，这一步做完了，但请坂口医生再确认。」"
		return inexperienced_nurse_response(staff_id, response_id, nurse_fallback)
	var dialogue_key := "intraoperative_correction" if correction else "intraoperative"
	var custom := str(roster[staff_id].get("team_dialogue", {}).get(dialogue_key, ""))
	if not custom.is_empty():
		return custom
	if correction:
		return "“I am not certain, but this does not match our preoperative verification. Please check it again.”" if english_mode() else "「我不敢确定，但这一步和术前核对不一致。请你重新确认。」"
	return "“I am unfamiliar with this field and followed your direction. The step is complete; please verify it.”" if english_mode() else "「我对术野不熟，只能按你的指示配合。这一步已经完成，请你再确认。」"

func assignment_response(role_id: String, staff_id: String = "") -> String:
	if not staff_id.is_empty():
		var scoped_response := procedure_group_team_dialogue(staff_id, "assignment")
		if not scoped_response.is_empty():
			return scoped_response
	if not staff_id.is_empty() and staff_has_low_surgery_proficiency(staff_id):
		if str(roster.get(staff_id, {}).get("profession", "")) == "nurse":
			var nurse_assignment := "“I am not experienced with surgical assistance, but I will try. Please explain each step clearly.”" if english_mode() else "「我不太擅长手术配合……既然需要，我会试试。请把每一步说清楚。」"
			return inexperienced_nurse_response(staff_id, "assignment_" + role_id, nurse_assignment)
		var custom := str(roster[staff_id].get("team_dialogue", {}).get("assignment", ""))
		if not custom.is_empty():
			return custom
		return "“I am not experienced with surgical assistance, but I will try. Please explain each step clearly.”" if english_mode() else "「我不太擅长手术配合……既然你需要，我会勉强试试。请把每一步说清楚。」"
	if english_mode():
		match role_id:
			"assistant_surgeon":
				return "“I will assist. Let us review the operative plan once more.”"
			"scrub_nurse":
				return "“I will scrub in and complete the instrument count in advance.”"
			"circulating_nurse":
				return "“I will handle circulation and documentation and report any change immediately.”"
			"ward_nurse":
				return "“Leave the ward preparation to me. I will explain everything to her again.”"
		return "“Understood. I will be ready.”"
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
		var nurse_fallback := "“I am not familiar with this step. Please verify it once more, Dr. Sakaguchi.”" if english_mode() else "「这个步骤我不太熟，请坂口医生再确认一次。」"
		return inexperienced_nurse_response(staff_id, action_id, nurse_fallback)
	var dialogue_key := str({
		"confirm_team": "confirmation",
		"confirm_assistant_role": "role_confirmation",
		"assistant_stabilize": "stabilize"
	}.get(action_id, ""))
	if dialogue_key.is_empty():
		return authored
	var scoped_response := procedure_group_team_dialogue(staff_id, dialogue_key)
	if not scoped_response.is_empty():
		return scoped_response
	var custom := str(roster.get(staff_id, {}).get("team_dialogue", {}).get(dialogue_key, ""))
	return authored if custom.is_empty() else custom

func presentation_staff() -> Dictionary:
	return roster.get(last_staff_id, {})

func presentation_staff_role() -> String:
	var role := role_definition(last_staff_role)
	return str(role.get("label", "Team Member" if english_mode() else "团队成员"))

func patient_reaction(reaction_id: String, fallback: String) -> String:
	# Patient-authored variants are presentation only. Numeric effects and routing
	# continue to come from the shared action, so personality cannot change outcome.
	var variants: Variant = patient_reaction_variants.get(reaction_id, [])
	if variants is Array and not variants.is_empty():
		var variant_index := posmod(hash("%s:%s:%s" % [patient_name, reaction_id, events.size()]), variants.size())
		return str(variants[variant_index])
	return str(runtime_english(patient_reactions.get(reaction_id, fallback)))

func operative_preparation_reaction_id(action_id: String) -> String:
	if flags.has("anesthetized") or action_id not in ["operative_positioning", "urinary_catheterization", "skin_disinfection", "incision_marking"]:
		return ""
	return action_id + ("_none" if flags.has("no_anesthesia_confirmed") else "_awake")

func operative_preparation_fallback(action_id: String) -> String:
	var without_anesthesia := flags.has("no_anesthesia_confirmed")
	match action_id:
		"operative_positioning":
			return "“Please do not restrain my hands... Do my legs have to remain at this angle?”" if english_mode() and without_anesthesia else "“The straps are a little tight... I will try to remain still.”" if english_mode() else "「不要固定我的手……我的腿也必须保持这个角度吗？」" if without_anesthesia else "「固定带有一点紧……我会尽量保持不动。」"
		"urinary_catheterization":
			return "“That is very uncomfortable—please stop!”" if english_mode() and without_anesthesia else "“It is uncomfortable... Please go slowly. I will cooperate.”" if english_mode() else "「啊……好难受，请停一下！」" if without_anesthesia else "「有些不舒服……请慢一点，我会配合。」"
		"skin_disinfection":
			return "“It is cold and stinging—my skin already hurts!”" if english_mode() and without_anesthesia else "“The antiseptic is cold... I will remain still.”" if english_mode() else "「又冷又刺，皮肤已经被擦得发疼了！」" if without_anesthesia else "「消毒液很凉……我会忍住不动。」"
		"incision_marking":
			return "“That line is so long... Are you really going to cut all of it? Stop!”" if english_mode() and without_anesthesia else "“The incision line is longer than I expected... Does it need to be this large?”" if english_mode() else "「这么长的线……真的要全部切开吗？先停下！」" if without_anesthesia else "「切口线比我想象得长……真的需要这么大吗？」"
	return ""

func patient_trait(id: String, fallback: int = 50) -> int:
	return clampi(int(patient_traits.get(id, fallback)), 0, 100)

func stress_response_text() -> String:
	match str(patient_personality.get("stress_response", "")):
		"becomes_quiet":
			return "withdraws into silence" if english_mode() else "沉默收缩"
		"seeks_reassurance":
			return "seeks reassurance" if english_mode() else "寻求确认"
		"becomes_irritable":
			return "openly distressed" if english_mode() else "急切外露"
		"asks_for_details":
			return "repeatedly asks for confirmation" if english_mode() else "反复确认"
	return "clear signs of stress" if english_mode() else "压力明显"

func preparation(id: String) -> Dictionary:
	for item in definition.preparations:
		if item.id == id:
			return item
	return {}

func mood_text() -> String:
	return ["relatively calm", "slightly uneasy", "tense", "very tense"][anxiety] if english_mode() else ["比较安心", "仍有些忐忑", "紧张", "非常紧张"][anxiety]

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
		return "anesthetized · stable response" if english_mode() else "麻醉中 · 反应平稳"
	if cooperation_value() <= 30:
		return ("nearly unable to cooperate · " if english_mode() else "接近失去配合 · ") + stress_response_text()
	if fear >= 70 or pain >= 70:
		return ("visibly frightened · " if english_mode() else "明显恐惧 · ") + stress_response_text()
	if fear >= 40:
		return "tense but still cooperating" if english_mode() else "紧张但仍在配合"
	return "relatively stable" if english_mode() else "状态相对平稳"

func interaction_summary() -> String:
	var procedure_summary := surgery_completion_text() + "\n" if surgery_success else ""
	if english_mode():
		if patient_event_count > 0:
			procedure_summary += "%s awake-patient interaction(s) were handled during surgery.\n" % patient_event_count
		if procedure_corrections > 0:
			procedure_summary += "The assistant corrected %s intraoperative decision(s) in time.\n" % procedure_corrections
		if procedure_mismatch:
			procedure_summary = "The selected procedure did not match the patient's scheduled operation. She was startled, and her fear rose sharply.\n" + procedure_summary
		if flags.has("anesthetized"):
			return procedure_summary + "The patient remained stable through the interaction phase under general anesthesia. Your response before induction still shaped her final experience."
		if cooperation_value() <= 30:
			return procedure_summary + "The patient managed to cooperate, but fear, pain, or pressure on her dignity exceeded the critical threshold."
		if fear <= 35 and dignity >= 80:
			return procedure_summary + "The patient always knew what would happen next and felt that her concerns were taken seriously."
		if cooperation_value() >= 70:
			return procedure_summary + "The patient completed the procedure despite visible tension; your responses kept the interaction stable."
		return procedure_summary + "The interaction phase ended. The patient cooperated, though some unease remained."
	if patient_event_count > 0:
		procedure_summary += "术中共处理%s次清醒患者互动。\n" % patient_event_count
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
	return "temporarily stable" if english_mode() else "暂时平稳"

func patient_visual_state() -> String:
	if current().scene == "operating_room":
		return "operating_room"
	return "preoperative" if flags.has("patient_prepared") else "gown"

func staff_outfit() -> String:
	return "scrubs" if flags.has("changed") else "default"

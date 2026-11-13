extends RefCounted
## Domain helper for Fujisaki Shiori's two-volume Lv3 arc:
## - Part A (`shiori_lv3_part_a_yuko_surgery`): clinic re-evaluation, spinal anesthesia,
##   live routine `surgery_appendix` Runner handoff with locked team & 13 custom lines,
##   and post-op ward rounds (settles `shiori_lv3_part_a_completed`, stays Lv2).
## - Part B (`shiori_lv3_part_b_dinner_walk`): suture-removal invite, four-person Italian
##   dinner with Yuko Asahina & Megumi Mikihara, night walk, and apartment-entrance
##   goodnight (atomically promotes `doc_shiori` Lv2 -> Lv3).
## Only event-level completion facts and story flags persist across safe boundaries.

const PreopSession = preload("res://godot/systems/preop_session.gd")
const OperativeBackgrounds = preload("res://godot/systems/operative_backgrounds.gd")

const MILESTONE_COOLDOWN_DAYS := 3

const ACTOR := "doc_shiori"
const LV1 := "shiori_lv1_doctors_worry"
const LV2 := "shiori_lv2_record_shop"
const PART_A := "shiori_lv3_part_a_yuko_surgery"
const PART_B := "shiori_lv3_part_b_dinner_walk"
const PART_A_DONE_FLAG := "shiori_lv3_part_a_completed"
const ACTION_SURGERY := "launch_shiori_lv3_yuko_surgery"
const STORY_PREOP_ID := "preop_shiori_lv3_yuko_appendix"
const STORY_VISIT_ID := "visit_shiori_lv3_yuko_appendix"
const STORY_PATIENT_ID := "story_patient_asahina_yuko"
const SURGERY_ID := "surgery_appendix"
const SURGERY_FLAG := "shiori_lv3_yuko_surgery"
const DIRECT_SURGERY_FLAG := "story_direct_surgery"

const PART_A_GAP_AFTER_LV2_DAYS := 28
const PART_B_GAP_AFTER_PART_A_DAYS := 6

const YUKO_OR_CAP_DIR := "assets/characters/story_patients/asahina_yuko/or_cap/"

const SECTION4_LINES := {
	"01_yuko_incision": {
		"zh_CN": "「呜……已经划开了吗？真的完全不疼诶……就是感觉右边肚皮上像有人拿手指轻轻划了一道线一样，好神奇……」",
		"en": "“Whoa... Did you already make the incision? It really doesn't hurt at all... It just feels like someone lightly traced a line across the right side of my belly with a finger—that's wild...”",
	},
	"02_shiori_entry": {
		"zh_CN": "「皮下小出血点我已经用纱布按住显露清楚了，坂口医生。电凝或者止血钳随时可以跟上。」",
		"en": "“I've pressed the small subcutaneous bleeders with gauze and exposed them clearly, Dr. Sakaguchi. Electrocautery or hemostats are ready whenever you want them.”",
	},
	"03_shiori_exposure": {
		"zh_CN": "「腹外斜肌腱膜已经顺纤维分开了。拉钩我往两侧再稳稳牵开一点——腹膜层很清晰，下面肠管没有粘在切口上。」",
		"en": "“The external oblique aponeurosis has split cleanly along its fibers. Let me draw the retractors a touch wider on both sides—the peritoneal layer is crisp and clear, with no bowel adherent beneath the incision.”",
	},
	"04_yuko_traction": {
		"zh_CN": "「等、等一下，刚才肚子里面是不是被什么东西往两边撑了一下？！不疼是不疼，可那种被拉扯的怪感觉是怎么回事呀！」",
		"en": "“W-wait a second—did something inside my belly just pull me open to both sides?! It doesn't hurt, sure, but what on earth is that weird tugging feeling?!”",
	},
	"05_yoneda_reassure": {
		"zh_CN": "「朝日奈小姐别紧张，那是拉钩牵开组织时的正常牵拉感，说明麻药效果很好哦。请慢慢用鼻子吸气、用嘴呼气。」",
		"en": "“Don't tense up, Ms. Asahina—that normal tugging sensation from the retractors means the spinal block is working really well. Please breathe in slowly through your nose and out through your mouth.”",
	},
	"06_shiori_identify": {
		"zh_CN": "「顺着结肠带往下看——找到了，坂口医生。阑尾尖端稍微往盲肠外侧偏了一点，近端明显肿胀发硬，里面确实嵌着那颗粪石。」",
		"en": "“Following the taenia coli downward—found it, Dr. Sakaguchi. The tip angles slightly lateral to the cecum, and the proximal segment is visibly swollen and indurated with that appendicolith wedged right inside.”",
	},
	"07_yuko_surreal": {
		"zh_CN": "「呜哇……诗织，听你用那么冷静的声音在帘子后面讨论我肚子里的肠子和石头，感觉比看恐怖片还要超现实啊……」",
		"en": "“Ughhh... Shiori, hearing you discuss the intestines and stone inside my open belly in that super calm voice from behind the drape feels way more surreal than watching a horror movie...”",
	},
	"08_hiroko_meso": {
		"zh_CN": "「弯血管钳和丝线递到您手上了，坂口医生。标本盘我也已经备在旁边。」",
		"en": "“Curved hemostat and silk ties in your hand, Dr. Sakaguchi. I have the specimen basin ready right beside us as well.”",
	},
	"09_shiori_base": {
		"zh_CN": "「系膜血管结扎得很牢，没有渗血。根部荷包缝线我已经帮您提稳角度了，随时可以包埋残端。」",
		"en": "“The mesoappendiceal vessels are securely ligated with zero oozing. I'm holding the purse-string suture at a steady angle at the base—ready to invert the stump whenever you give the word.”",
	},
	"10_yuko_resection": {
		"zh_CN": "「唔……刚才肚子深处好像拽了一下又突然松开了……那颗害我疼了好几次的坏石头，是不是已经被拿走啦？」",
		"en": "“Mmph... Something deep inside my belly just gave a tug and then suddenly let go... Does that mean the nasty stone that kept making me hurt is finally gone?”",
	},
	"11_nurses_count": {
		"zh_CN": "「关腹前清点：纱布、缝针、器械数目核对一致，全部正确！」",
		"en": "“Pre-closure count: sponges, needles, and instruments all match—counts are completely correct!”",
	},
	"12_shiori_closure": {
		"zh_CN": "「腹膜和肌层对合得很平整，剪线交给我。朝日奈……夕子酱，再坚持最后两分钟，马上就缝完表皮了。」",
		"en": "“The peritoneum and muscle layers are coming together cleanly—leave cutting the sutures to me. Asahina... Yuko-chan, hang in there for just two more minutes; we're almost finished closing the skin.”",
	},
	"13_shiori_comfort": {
		"zh_CN": "「别怕，夕子酱，心率稍微快了一点而已，我和坂口医生都在这儿盯着呢，每一步都很顺利。」",
		"en": "“Don't be scared, Yuko-chan—your heart rate just ticked up a tiny bit. Dr. Sakaguchi and I are right here watching everything closely, and every step is going smoothly.”",
	},
}

static func owns(id: String) -> bool:
	return id in [PART_A, PART_B]

static func is_story_surgery(prep: RefCounted) -> bool:
	return prep != null and prep.flags.has(SURGERY_FLAG)

static func safe(g: RefCounted) -> bool:
	return not (g.active_surgery_committed() or g.active_surgery_in_progress() or g.active_encounter_in_progress() or not g.active_preop_id.is_empty() or not g.active_special_event_id.is_empty() or not g.active_character_event_id.is_empty() or not g.active_micro_event_id.is_empty() or not g.active_after_work_walk.is_empty() or not g.active_free_h_departure.is_empty() or not g.pending_departure_context().is_empty() or g.active_adult_intimacy != null)

static func _milestone_cooldown_clear(g: RefCounted, event_day: int) -> bool:
	var relation: Dictionary = g.relation_for(ACTOR)
	if relation.is_empty():
		return false
	var latest_milestone_day := 0
	for rank_event_id in relation.get("rank_history", []):
		var completed_event = g.character_events.get(str(rank_event_id))
		if completed_event != null:
			latest_milestone_day = maxi(latest_milestone_day, int(completed_event.completed_day))
	if latest_milestone_day <= 0:
		return true
	var cooldown_days := maxi(MILESTONE_COOLDOWN_DAYS, int(g.relationship_rank_slot(ACTOR, 3).get("cooldown_days", MILESTONE_COOLDOWN_DAYS)))
	return event_day >= latest_milestone_day + cooldown_days

static func eligible(g: RefCounted, id: String) -> bool:
	if not owns(id) or not safe(g):
		return false
	if not g.staff_is_met(ACTOR) or not g.staff_is_met("nurse_hiroko"):
		return false
	if g.relationship_level(ACTOR) != 2 or not g.relationship_rank_gate_met(ACTOR, 3):
		return false
	var today := int(g.day_number())
	if g.is_hospital_closed_day(today):
		return false
	if id == PART_A:
		if g.character_event_done(PART_A) or g.character_event_done(PART_B):
			return false
		if not g.character_event_done(LV2):
			return false
		var lv2_event = g.character_events.get(LV2)
		if lv2_event == null or int(lv2_event.completed_day) <= 0:
			return false
		if today < int(lv2_event.completed_day) + PART_A_GAP_AFTER_LV2_DAYS:
			return false
		if not _milestone_cooldown_clear(g, today):
			return false
		# Tomorrow morning 08:30 is Yuko's elective appendectomy + 15:30 ward rounds.
		if g.is_hospital_closed_day(today + 1):
			return false
		return true
	if id == PART_B:
		if not g.character_event_done(PART_A) or g.character_event_done(PART_B):
			return false
		var part_a_event = g.character_events.get(PART_A)
		if part_a_event == null or int(part_a_event.completed_day) <= 0:
			return false
		if today < int(part_a_event.completed_day) + PART_B_GAP_AFTER_PART_A_DAYS:
			return false
		# Scene B2 takes place two evenings later right after afternoon outpatient clinic.
		if g.is_hospital_closed_day(today + 2):
			return false
		return true
	return false

static func prepare_test_save(g: RefCounted, event_id: String, base_day: int) -> int:
	g.meet_staff(ACTOR)
	g.meet_staff("nurse_hiroko")
	var relation: Dictionary = g.relation_for(ACTOR)
	relation.met = true
	relation.level = 2
	relation.familiarity = maxi(int(relation.get("familiarity", 0)), 40)
	for milestone_id in [LV1, LV2]:
		if not relation.rank_history.has(milestone_id):
			relation.rank_history.append(milestone_id)
	g.set_test_player_attribute("skill", 65)
	g.set_test_player_attribute("charm", 30)
	g._complete_character_event_for_test(LV1, 2)
	g._complete_character_event_for_test(LV2, 6)
	g.set_story_flag("shiori_lv2_complete", true)
	g.set_story_flag("shiori_asahina_yuko_consulted", true)
	g.set_story_flag("shiori_classical_records_shared", true)
	var target_day := maxi(base_day, 6 + PART_A_GAP_AFTER_LV2_DAYS)
	if event_id == PART_A:
		while target_day < g.GAME_DURATION_DAYS and (g.is_hospital_closed_day(target_day) or g.is_hospital_closed_day(target_day + 1)):
			target_day += 1
		return target_day
	var part_a_day := 34
	while part_a_day < g.GAME_DURATION_DAYS and (g.is_hospital_closed_day(part_a_day) or g.is_hospital_closed_day(part_a_day + 1)):
		part_a_day += 1
	g._complete_character_event_for_test(PART_A, part_a_day)
	if not relation.event_history.has(PART_A):
		relation.event_history.append(PART_A)
	g.set_story_flag(PART_A_DONE_FLAG, true)
	target_day = maxi(target_day, part_a_day + PART_B_GAP_AFTER_PART_A_DAYS)
	while target_day < g.GAME_DURATION_DAYS and (g.is_hospital_closed_day(target_day) or g.is_hospital_closed_day(target_day + 2)):
		target_day += 1
	return target_day

static func line_text(key: String, english: bool) -> String:
	var entry: Dictionary = SECTION4_LINES.get(key, {})
	return str(entry.get("en" if english else "zh_CN", ""))

static func patient_record(english: bool) -> Dictionary:
	return {
		"id": STORY_PATIENT_ID,
		"name": "Yuko Asahina" if english else "朝日奈夕子",
		"age": 25,
		"gender": "female",
		"adult": true,
		"traits": {
			"anxiety_sensitivity": 45,
			"pain_sensitivity": 45,
			"shame_sensitivity": 60,
			"trust_openness": 80,
			"control_need": 45,
		},
		"visuals": {
			"color": "E06B8B",
			"default_outfit": "intraoperative",
			"portraits": {
				"intraoperative/neutral": YUKO_OR_CAP_DIR + "curious_awake.png",
				"intraoperative/tense": YUKO_OR_CAP_DIR + "nervous_sweat.png",
				"intraoperative/curious_awake": YUKO_OR_CAP_DIR + "curious_awake.png",
				"intraoperative/startled_yelp": YUKO_OR_CAP_DIR + "startled_yelp.png",
				"intraoperative/nervous_sweat": YUKO_OR_CAP_DIR + "nervous_sweat.png",
				"intraoperative/shocked_panic": YUKO_OR_CAP_DIR + "shocked_panic.png",
				"intraoperative/embarrassed_blush": YUKO_OR_CAP_DIR + "embarrassed_blush.png",
				"intraoperative/relieved_warm_smile": YUKO_OR_CAP_DIR + "relieved_warm_smile.png",
				"operating_room/neutral": YUKO_OR_CAP_DIR + "relieved_warm_smile.png",
				"ward/neutral": "assets/characters/story_patients/asahina_yuko/ward/relieved.png",
			},
		},
	}

static func intraoperative_expression(prep: RefCounted) -> String:
	var step: Dictionary = prep.surgery_flow_step()
	var step_id := str(step.get("id", ""))
	match step_id:
		"appendix_01_entry":
			return "curious_awake"
		"appendix_02_exposure":
			return "startled_yelp"
		"appendix_03_identify":
			return "embarrassed_blush"
		"appendix_04_mobilize", "appendix_05_mesappendix", "appendix_06_base":
			return "nervous_sweat"
		"appendix_07_resection":
			return "curious_awake"
		"appendix_08_review", "appendix_09_closure":
			return "relieved_warm_smile"
	return "curious_awake"

static func build_preop_blueprint(g: RefCounted) -> Dictionary:
	var english: bool = str(g.patient_content_locale()) == "en"
	var base_template: Dictionary = {}
	for candidate in g.preop_blueprints.values():
		base_template = candidate.duplicate(true)
		break
	var patient := patient_record(english)
	base_template["id"] = STORY_PREOP_ID
	base_template["encounter_id"] = STORY_VISIT_ID
	base_template["patient_id"] = STORY_PATIENT_ID
	base_template["surgery_id"] = SURGERY_ID
	base_template["title"] = "%s · %s" % [patient.name, "Open Appendectomy" if english else "开腹阑尾切除术"]
	base_template["story_direct_surgery"] = true
	return base_template

static func start_or_reset_story_surgery(g: RefCounted) -> RefCounted:
	var english: bool = str(g.patient_content_locale()) == "en"
	var definition := build_preop_blueprint(g)
	var prep_patients: Array = g.patient_definitions.duplicate()
	prep_patients.append(patient_record(english))
	var prep := PreopSession.new(
		definition,
		g.staff,
		g.surgery_definitions,
		prep_patients,
		[],
		false,
		g.surgery_team_dialogue_profiles,
		g.patient_interaction_definitions,
		g.temporary_condition_definitions,
		[SURGERY_ID],
		false,
		g.palpation_profile_definitions,
		g.awake_special_bark_definitions
	)
	prep.temporary_conditions_enabled = false
	prep.team = {
		"assistant_surgeon": ACTOR,
		"scrub_nurse": "nurse_hiroko",
		"circulating_nurse": "nurse_yoneda_shiori",
	}
	var surgery: Dictionary = prep.surgeries.get(SURGERY_ID, {})
	prep.procedure_id = SURGERY_ID
	prep.procedure_name = str(surgery.get("name", "Open Appendectomy" if english else "开腹阑尾切除"))
	prep.procedure_minutes = int(surgery.get("duration_minutes", 60))
	prep.procedure_extra_minutes = 0
	prep.procedure_mismatch = false
	prep.case_variant_id = "standard"
	prep.resolved_random_choices = {"case_variant": "standard"}
	prep.surgery_rng_seed = 20261112
	prep.initialize_procedure_state(SURGERY_ID)
	prep.clamp_procedure_state()
	prep.procedure_step_index = 0
	prep.procedure_step_history.clear()
	prep.procedure_corrections = 0
	prep.anesthesia = "Spinal Anesthesia" if english else "腰麻"
	prep.operative_background_id = str(OperativeBackgrounds.IDS[0])
	prep.stage_id = "procedure_flow"
	prep.fear = 24
	prep.pain = 0
	prep.dignity = 88
	prep.cooperation_base = 88
	prep.lowest_dignity_seen = prep.dignity
	prep.lowest_cooperation_seen = prep.cooperation_base
	prep.peak_fear_seen = prep.fear
	prep.peak_pain_seen = prep.pain
	prep.flags.clear()
	prep.flags.append_array([
		"changed",
		"hands_ready",
		"patient_prepared",
		"team_confirmed",
		"or_table_palpation_complete",
		"anesthesia_chosen",
		"epidural_anesthesia",
		"spinal_anesthesia",
		"anesthesia_sensory_test_complete",
		"incision_made",
		"surgery_started",
		DIRECT_SURGERY_FLAG,
		SURGERY_FLAG,
	])
	# Enter appendix_01_entry immediately displaying Yuko's Section 4 Line #1 bark.
	var entry_bark := line_text("01_yuko_incision", bool(prep.english_mode()))
	prep.active_patient_interaction = {
		"id": "shiori_lv3_yuko_entry_bark",
		"prompt": entry_bark,
		"speaker": "patient",
		"actions": [],
		"background_bark": true,
	}
	prep.feedback = entry_bark
	prep.feedback_speaker = "patient"
	prep.last_staff_id = ""
	prep.last_staff_role = ""
	prep.pending_flow_stage_id = ""
	prep.awaiting_patient_acknowledgement = true
	g.preops[STORY_PREOP_ID] = prep
	g.active_preop_id = STORY_PREOP_ID
	g.active_id = ""
	g.active_mode = "preop"
	return prep

static func option_response_override(prep: RefCounted, flow_step: Dictionary) -> Dictionary:
	if not is_story_surgery(prep):
		return {}
	var english: bool = bool(prep.english_mode())
	var step_id := str(flow_step.get("id", ""))
	match step_id:
		"appendix_01_entry":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("02_shiori_entry", english),
			}
		"appendix_02_exposure":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("03_shiori_exposure", english),
			}
		"appendix_03_identify":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("06_shiori_identify", english),
			}
		"appendix_04_mobilize":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("13_shiori_comfort", english),
			}
		"appendix_05_mesappendix":
			return {
				"role": "scrub_nurse",
				"staff_id": "nurse_hiroko",
				"line": line_text("08_hiroko_meso", english),
			}
		"appendix_06_base":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("09_shiori_base", english),
			}
		"appendix_08_review":
			return {
				"role": "scrub_nurse",
				"staff_id": "nurse_hiroko",
				"speaker_prefix": "Hiroko Sugimura & Shiori Yoneda：" if english else "杉村弘子 ＆ 米田栞：",
				"line": line_text("11_nurses_count", english),
			}
		"appendix_09_closure":
			return {
				"role": "assistant_surgeon",
				"staff_id": ACTOR,
				"line": line_text("12_shiori_closure", english),
			}
	return {}

static func resolve_stage_patient_event(prep: RefCounted, flow_step: Dictionary) -> bool:
	if not is_story_surgery(prep):
		return false
	var english: bool = bool(prep.english_mode())
	var step_id := str(flow_step.get("id", ""))
	match step_id:
		"appendix_02_exposure":
			var prompt_02 := line_text("04_yuko_traction", english)
			prep.active_patient_interaction = {
				"id": "shiori_lv3_yuko_traction_02",
				"prompt": prompt_02,
				"speaker": "patient",
				"actions": [
					{
						"id": "yoneda_reassure_breathing",
						"label": "Ask Shiori Yoneda to reassure Yuko and guide her breathing" if english else "示意巡回护士米田栞安抚夕子并引导呼吸",
						"delegate_role": "circulating_nurse",
						"response": line_text("05_yoneda_reassure", english),
						"response_speaker": "staff",
						"minutes": 0,
						"presence_delta": 0,
						"effects": {"fear": -4, "cooperation": 5, "dignity": 2, "pain": 0},
					},
				],
			}
			prep.patient_interaction_history.append("shiori_lv3_yuko_traction_02")
			prep.patient_event_consumed_this_stage = true
			prep.patient_event_count += 1
			prep.awaiting_patient_choice = true
			prep.feedback = prompt_02
			prep.feedback_speaker = "patient"
			prep.last_staff_id = ""
			prep.last_staff_role = ""
			return true
		"appendix_03_identify":
			var bark_03 := line_text("07_yuko_surreal", english)
			prep.awake_special_bark_history.append("shiori_lv3_yuko_surreal_03")
			prep.patient_event_consumed_this_stage = true
			prep.active_patient_interaction = {
				"id": "shiori_lv3_yuko_surreal_03",
				"prompt": bark_03,
				"speaker": "patient",
				"actions": [],
				"background_bark": true,
			}
			prep.feedback = bark_03
			prep.feedback_speaker = "patient"
			prep.last_staff_id = ""
			prep.last_staff_role = ""
			prep.awaiting_patient_acknowledgement = true
			return true
		"appendix_07_resection":
			var bark_07 := line_text("10_yuko_resection", english)
			prep.awake_special_bark_history.append("shiori_lv3_yuko_resection_07")
			prep.patient_event_consumed_this_stage = true
			prep.active_patient_interaction = {
				"id": "shiori_lv3_yuko_resection_07",
				"prompt": bark_07,
				"speaker": "patient",
				"actions": [],
				"background_bark": true,
			}
			prep.feedback = bark_07
			prep.feedback_speaker = "patient"
			prep.last_staff_id = ""
			prep.last_staff_role = ""
			prep.awaiting_patient_acknowledgement = true
			return true
	return false

static func crisis_resolution_append_line(prep: RefCounted) -> String:
	if not is_story_surgery(prep):
		return ""
	var english: bool = bool(prep.english_mode())
	var shiori_name := str(prep.roster.get(ACTOR, {}).get("name", "Shiori Fujisaki" if english else "藤崎 詩織"))
	return "%s：%s" % [shiori_name, line_text("13_shiori_comfort", english)]

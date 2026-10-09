extends RefCounted
const StageArt = preload("res://godot/ui/preop_stage_art.gd")
const UI = preload("res://godot/ui/clinic_view.gd")
const OR_TABLE_PALPATION_IMAGES := {
	"prototype_v1": "res://assets/surgeries/palpation/or_table_torso_prototype_v1.png",
	"body_type_02": "res://assets/surgeries/palpation/or_table_torso_body_type_02.png",
	"body_type_03": "res://assets/surgeries/palpation/or_table_torso_body_type_03.png",
	"body_type_04": "res://assets/surgeries/palpation/or_table_torso_body_type_04.png",
}
const OR_TABLE_PALPATION_HOTSPOT_REFERENCE_SIZE := Vector2(620, 626)
# Hotspots are authored in local coordinates inside the 620x626 palpation image.
# Each CG needs its own map because body proportions and source-image cropping vary.
const OR_TABLE_PALPATION_HOTSPOTS := {
	"prototype_v1": {
		"breast": [Rect2(140, 80, 160, 170), Rect2(320, 80, 160, 170)],
		"nipple": [Rect2(178, 132, 48, 48), Rect2(372, 132, 48, 48)],
		"chest": [Rect2(280, 24, 70, 222)],
		"abdomen": [Rect2(185, 232, 250, 250)],
		"genital": [Rect2(240, 490, 140, 136)],
	},
	"body_type_02": {
		"breast": [Rect2(115, 57, 175, 200), Rect2(290, 57, 185, 200)],
		"nipple": [Rect2(136, 160, 48, 48), Rect2(386, 160, 48, 48)],
		"chest": [Rect2(274, 20, 70, 220)],
		"abdomen": [Rect2(167, 243, 282, 307)],
		"genital": [Rect2(234, 534, 128, 92)],
	},
	"body_type_03": {
		"breast": [Rect2(160, 42, 150, 180), Rect2(310, 42, 165, 180)],
		"nipple": [Rect2(180, 137, 48, 48), Rect2(383, 137, 48, 48)],
		"chest": [Rect2(288, 22, 55, 210)],
		"abdomen": [Rect2(187, 225, 249, 300)],
		"genital": [Rect2(233, 516, 154, 110)],
	},
	"body_type_04": {
		"breast": [Rect2(160, 38, 145, 198), Rect2(305, 38, 155, 198)],
		"nipple": [Rect2(176, 135, 48, 48), Rect2(374, 135, 48, 48)],
		"chest": [Rect2(282, 23, 50, 210)],
		"abdomen": [Rect2(181, 228, 259, 297)],
		"genital": [Rect2(231, 513, 160, 113)],
	},
}
const OPERATIVE_FIELD_OVERLAY_POOLS := {
	"procedure:surgery_appendix": [
		"res://assets/surgeries/overlays/appendix/open_appendix_field_01.png",
		"res://assets/surgeries/overlays/appendix/open_appendix_field_02.png",
	],
	"group:female_pelvic": [
		"res://assets/surgeries/overlays/pelvic/open_pelvic_field.png",
		"res://assets/surgeries/overlays/pelvic/open_pelvic_field_02.png",
	],
	"group:general_abdominal": [
		"res://assets/surgeries/overlays/abdominal/open_abdominal_field_01.png",
		"res://assets/surgeries/overlays/abdominal/open_abdominal_field_02.png",
	],
	"group:breast": [
		"res://assets/surgeries/overlays/breast/open_breast_field_01.png",
		"res://assets/surgeries/overlays/breast/open_breast_field_02.png",
		"res://assets/surgeries/overlays/breast/open_breast_field_03.png",
	],
	"group:cardiac": [
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_01.png",
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_02.png",
	],
	"group:thoracic": [
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_01.png",
		"res://assets/surgeries/overlays/thoracic/open_thoracic_field_02.png",
	],
}

static func background_id_for(stage: Dictionary, flags: Array, operative_scene: bool, operative_background_id: String) -> String:
	if operative_scene:
		return operative_background_id
	if stage.kind == "changing" and flags.has("changed"):
		return "scrub_area"
	return str(stage.background_id)

static func render(app: Control, prep: RefCounted) -> void:
	var patient: Dictionary = app.content.find_record("patients", prep.definition.patient_id)
	var stage: Dictionary = prep.current()
	if stage.kind in ["or_table_palpation", "anesthesia_sensory_test"]:
		render_or_table_palpation(app, prep, patient)
		return
	var flow_step: Dictionary = prep.surgery_flow_step() if stage.kind == "surgery_flow" else {}
	var stage_title: String = str(flow_step.get("title", stage.title))
	var transition_title: String = app.tx("ui.auto.bdb1bd559f36", "患者临时状况") if not prep.active_condition_id.is_empty() else app.tx("ui.auto.b671cc5de186", "患者术中回应") if prep.feedback_speaker == "patient" else app.tx("ui.auto.7ec1097aa6ab", "团队处理回应") if prep.feedback_speaker == "staff" else app.tx("ui.auto.d5e064082dcc", "术中阶段记录")
	var patient_event_visible: bool = stage.kind == "surgery_flow" and (prep.awaiting_patient_choice or prep.awaiting_patient_acknowledgement)
	var page_title: String = transition_title if patient_event_visible else app.tx("ui.auto.248ccc57247d", "术中团队回应") if stage.kind == "surgery_flow" and prep.awaiting_flow_acknowledgement else app.tx("ui.auto.8f41e64b6153", "术中团队配合") if stage.kind == "surgery_flow" else app.tx("ui.auto.85af4f25fc09", "手术室里的回应") if stage.kind in ["interaction", "surgery_complete"] else prep.definition.title
	var operative_scene: bool = stage.scene == "operating_room" and prep.flags.has("incision_made") and not prep.operative_background_id.is_empty()
	# Changing clothes and scrubbing share one authored stage, but they happen in
	# different rooms. Once the player has changed, move the remainder of this
	# stage to the dedicated scrub area.
	var active_background_id := background_id_for(stage, prep.flags, operative_scene, prep.operative_background_id)
	app.base(page_title, "%s / %s" % [patient.name, stage_title], false, active_background_id)
	var field_visual_visible := operative_field_overlay_visible(prep, stage, flow_step)
	if field_visual_visible:
		if app.operative_field_hud_enabled:
			add_operative_field_hud(app, prep)
		else:
			add_operative_field_overlay(app, prep)
	var map_action: Callable = app.finish_aborted_surgery_and_return if prep.surgery_aborted else app.finish_surgery_and_return if prep.surgery_success else app.show_map
	var map_button: Button = app.button_at(app.tx("ui.auto.53c4c7fe6bb3", "← 医院导览"), Vector2(1040, 88), Vector2(180, 44), map_action)
	if prep.surgery_committed() or prep.graphic_preop_dialogue_locked():
		map_button.disabled = true
		map_button.tooltip_text = app.tx("ui.preop.graphic.locked", "请先完成这段术前说明。") if prep.graphic_preop_dialogue_locked() else app.tx("ui.notice.surgery_committed", "手术团队已经确认，必须完成本次手术后才能离开。")
	var speaking_staff: Dictionary = prep.presentation_staff()
	# Operating-table art is an intentional framed inset. Ward patients and staff
	# are transparent character cutouts and sit directly over the room background.
	if not operative_scene and speaking_staff.is_empty() and stage.scene == "operating_room":
		var table_frame := UI.panel(app, Vector2(755, 180), Vector2(466, 362))
		table_frame.name = "OperatingTableFrame"
	var art: Control = null
	if not operative_scene:
		art = StageArt.new()
		art.name = "PreopStageArt"
		art.position = Vector2(760, 178)
		art.size = Vector2(450, 365)
		art.scene_id = stage.scene
		art.anxiety = prep.anxiety
		art.changed = prep.flags.has("changed")
		app.page.add_child(art)
	var show_staff_portrait: bool = not speaking_staff.is_empty() and (not operative_scene or (stage.kind == "surgery_flow" and (prep.awaiting_flow_acknowledgement or prep.awaiting_patient_acknowledgement or not prep.active_crisis.is_empty())))
	var show_intraoperative_patient: bool = operative_scene and speaking_staff.is_empty() and (stage.kind != "surgery_flow" or prep.awaiting_patient_choice or prep.awaiting_patient_acknowledgement)
	if show_staff_portrait:
		if art != null:
			art.visible = false
		var staff_outfit := operating_room_outfit(speaking_staff) if stage.scene == "operating_room" else str(speaking_staff.visuals.default_outfit)
		var staff_expression := "focused" if stage.scene == "operating_room" else "smile"
		var staff_portraits: Dictionary = speaking_staff.get("visuals", {}).get("portraits", {})
		if not prep.active_crisis.is_empty() and staff_portraits.has(staff_outfit + "/worried"):
			staff_expression = "worried"
		elif prep.staff_has_low_surgery_proficiency(str(speaking_staff.id)) and staff_portraits.has(staff_outfit + "/worried"):
			staff_expression = "worried"
		var use_hud_avatar: bool = field_visual_visible and app.operative_field_hud_enabled and staff_portraits.has("intraoperative_avatar/neutral")
		app.add_portrait(speaking_staff, "neutral" if use_hud_avatar else staff_expression, "intraoperative_avatar" if use_hud_avatar else staff_outfit)
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.name = "StaffInteractionPortrait"
			portrait.position = Vector2(760, 348) if field_visual_visible and app.operative_field_hud_enabled else Vector2(760, 185)
			portrait.size = Vector2(450, 172) if field_visual_visible and app.operative_field_hud_enabled else Vector2(450, 310)
		app.label_at("%s · %s" % [speaking_staff.name, prep.presentation_staff_role()], Vector2(785, 525) if field_visual_visible and app.operative_field_hud_enabled else Vector2(785, 508), 18, Color("f4f0e6"), 410)
	elif show_intraoperative_patient:
		var intraoperative_expression := intraoperative_patient_expression(prep)
		app.add_portrait(patient, intraoperative_expression, "intraoperative")
		var portrait = app.page.get_node_or_null("CharacterPortrait")
		if portrait != null:
			portrait.name = "IntraoperativePatientPortrait"
			portrait.position = Vector2(760, 348) if field_visual_visible and app.operative_field_hud_enabled else Vector2(760, 185)
			portrait.size = Vector2(450, 172) if field_visual_visible and app.operative_field_hud_enabled else Vector2(450, 310)
		app.label_at("%s · %s" % [patient.name, prep.patient_state_text()], Vector2(785, 525) if field_visual_visible and app.operative_field_hud_enabled else Vector2(785, 508), 18, Color("f4f0e6"), 410)
	elif not operative_scene:
		var use_examination_portrait := manual_ward_examination_portrait(prep, stage)
		var patient_expression := "shy" if use_examination_portrait else expression_for_patient(prep, stage)
		var patient_outfit := "examination" if use_examination_portrait else operating_table_outfit(prep, patient, patient_expression) if stage.scene == "operating_room" else "ward"
		if stage.scene in ["ward", "operating_room"] and patient.get("visuals", {}).get("portraits", {}).has(patient_outfit + "/" + patient_expression):
			art.visible = false
			app.add_portrait(patient, patient_expression, patient_outfit)
			var portrait = app.page.get_node_or_null("CharacterPortrait")
			if portrait != null:
				portrait.position = Vector2(760, 185)
				portrait.size = Vector2(450, 310)
		var state_text: String = prep.patient_state_text() if stage.scene == "operating_room" else prep.mood_text()
		app.label_at("%s · %s" % [patient.name, state_text], Vector2(785, 508), 18, Color("f4f0e6"), 410)

	var action_y := 255
	var action_spacing := 72
	var preparation_sweep_id := ""
	match stage.kind:
		"graphic_preop_choice":
			app.pause_dialogue_for_choice()
		"graphic_preop_dialogue":
			var node_total: int = prep.graphic_preop_nodes.size()
			var node_number: int = prep.graphic_preop_node_index + 1
			app.label_at(app.tx("ui.preop.graphic.progress", "术前说明　%s / %s") % [node_number, node_total], Vector2(65, 205), 21, Color("e8cfaa"), 640)
			var dialogue_continue: Button = app.button_at(app.tx("ui.preop.graphic.continue", "继续听说明  →"), Vector2(60, 315), Vector2(655, 54), app.preop_event.bind({"kind": "graphic_preop_next"}))
			dialogue_continue.name = "GraphicPreopContinue"
			app.register_dialogue_continue(dialogue_continue, prep.feedback)
			app.add_dialogue_playback_controls()
			action_y = 900
		"team":
			app.label_at(app.tx("ui.auto.4ca46634c12d", "主刀 / 你"), Vector2(62, 190), 21, Color("e8cfaa"), 640)
			for i in range(prep.definition.roles.size()):
				role_picker(app, prep, prep.definition.roles[i], 244 + i * 75)
			app.label_at(app.tx("ui.auto.a66dd1871661", "未进团队的护士将负责病房准备。"), Vector2(65, 460), 16, Color("c2d2cc"), 640)
			action_y = 492
		"preparation":
			role_picker(app, prep, prep.definition.ward_role, 190)
			app.label_at(app.tx("ui.auto.d27a1741ec39", "必做：核对资料与准备状态"), Vector2(65, 261), 20, Color("e8cfaa"), 650)
			for i in range(prep.definition.preparations.size()):
				var item: Dictionary = prep.definition.preparations[i]
				var check := CheckButton.new()
				check.name = "Preparation_" + item.id
				check.text = app.tx("ui.auto.5650688f06db", "%s  ·  %s 分钟") % [item.label, item.minutes]
				check.position = Vector2(60, 299 + i * 48)
				check.size = Vector2(650, 43)
				check.button_pressed = prep.selected_preparations.has(item.id)
				check.disabled = not check.button_pressed and prep.selected_preparations.size() >= prep.definition.max_optional_preparations
				check.toggled.connect(func(_pressed: bool): app.preop_event({"kind": "toggle", "id": item.id}))
				app.page.add_child(check)
			var instruction: String = app.tx("ui.auto.d3195ea0e42b", "额外照顾 %s / %s · 选择由护士完成，或由你亲手执行") % [prep.selected_preparations.size(), prep.definition.max_optional_preparations]
			if not prep.team.has(prep.definition.ward_role.id):
				instruction = app.tx("ui.auto.7fb2f6e70921", "请先在上方指派病房准备护士，才能执行准备。")
			app.label_at(instruction, Vector2(65, 451), 17, Color("e8cfaa"), 640)
			var indicated_surgery_id := str(prep.definition.get("surgery_id", ""))
			if not indicated_surgery_id.is_empty() and app.game.procedure_sweep_unlocked(indicated_surgery_id):
				preparation_sweep_id = indicated_surgery_id
			action_y = 492
		"changing":
			app.label_at(app.tx("ui.auto.a16c26df14eb", "服装：%s  /  刷手：%s") % [app.tx("ui.auto.989ccdbea001", "手术服") if prep.flags.has("changed") else app.tx("ui.auto.d66e4ceb993b", "日常服装"), app.tx("ui.auto.33246f6a5e5b", "完成") if prep.flags.has("hands_ready") else app.tx("ui.auto.f9ddfd643456", "待完成")], Vector2(65, 195), 21, Color("e8cfaa"), 655)
		"surgery_select":
			app.label_at(app.tx("ui.auto.b00628a7283a", "术式耗时会立即计入工作日时间。"), Vector2(65, 183), 19, Color("e8cfaa"), 640)
			var procedure_scroll := ScrollContainer.new()
			procedure_scroll.name = "ProcedureList"
			procedure_scroll.position = Vector2(60, 220)
			procedure_scroll.size = Vector2(655, 320)
			var procedure_list := VBoxContainer.new()
			procedure_list.custom_minimum_size.x = 625
			procedure_list.add_theme_constant_override("separation", 8)
			procedure_scroll.add_child(procedure_list)
			app.page.add_child(procedure_scroll)
			for surgery in prep.surgery_options():
				var procedure_row := HBoxContainer.new()
				procedure_row.custom_minimum_size = Vector2(625, 50)
				procedure_row.add_theme_constant_override("separation", 8)
				procedure_list.add_child(procedure_row)
				var procedure_button := Button.new()
				var unlocked: bool = prep.procedure_unlocked(str(surgery.id))
				var can_sweep: bool = unlocked and str(surgery.id) == str(prep.definition.surgery_id) and app.game.procedure_sweep_unlocked(str(surgery.id))
				var prefix := "" if unlocked else "🔒 "
				procedure_button.text = app.tx("ui.auto.46e12e48717d", "%s%s　·　%s　·　推荐技术 %s") % [prefix, surgery.name, prep.duration_text(int(surgery.duration_minutes)), surgery.recommended_surgery]
				procedure_button.custom_minimum_size = Vector2(457 if can_sweep else 625, 50)
				procedure_button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
				procedure_button.pressed.connect(app.preop_event.bind({"kind": "procedure", "id": surgery.id}))
				procedure_button.name = "Procedure_" + surgery.id
				procedure_button.disabled = not unlocked
				procedure_button.tooltip_text = prep.procedure_lock_reason(str(surgery.id))
				procedure_button.add_theme_stylebox_override("disabled", app.panel_style(Color("24343b")))
				procedure_button.add_theme_color_override("font_disabled_color", Color("84969a"))
				procedure_row.add_child(procedure_button)
				if can_sweep:
					var sweep_button := Button.new()
					sweep_button.name = "ProcedureSweep_" + str(surgery.id)
					sweep_button.text = app.tx("ui.surgery.sweep", "一键扫荡")
					sweep_button.custom_minimum_size = Vector2(160, 50)
					sweep_button.tooltip_text = app.tx("ui.surgery.sweep_hint", "立即完成已成功做过的术式，并获得经验、声望与团队熟悉度。")
					sweep_button.pressed.connect(app.sweep_surgery.bind(str(surgery.id)))
					procedure_row.add_child(sweep_button)
			action_y = 900
		"interaction":
			app.label_at(app.tx("ui.auto.c97c67f01486", "麻醉：") + prep.anesthesia, Vector2(65, 183), 19, Color("e8cfaa"), 640)
			metric(app, app.tx("ui.auto.b026d89cdd27", "恐惧"), prep.fear, Vector2(65, 218), Color("d47f79"))
			metric(app, app.tx("ui.auto.508510701136", "痛苦"), prep.pain, Vector2(380, 218), Color("d6a06c"))
			metric(app, app.tx("ui.auto.1147ce7d901f", "尊严"), prep.dignity, Vector2(65, 258), Color("79a9c9"))
			metric(app, app.tx("ui.auto.caf567d6a006", "配合"), prep.cooperation_value(), Vector2(380, 258), Color("7eb696"))
			action_y = 305
			action_spacing = 58
		"surgery_flow":
			var choice_panel := UI.panel(app, Vector2(42, 164), Vector2(700, 370))
			choice_panel.name = "SurgeryChoicePanel"
			var flow: Array = prep.surgery_flow_steps()
			var condition_status: String = prep.temporary_condition_status_text()
			var flow_heading: String = app.tx("ui.auto.65113f75dcf1", "%s · 步骤 %s") % [prep.procedure_name, prep.surgery_step_display_label()]
			if not condition_status.is_empty():
				flow_heading += " · " + condition_status
			app.label_at(flow_heading, Vector2(65, 183), 19, Color("e8cfaa"), 640)
			var strategy_status: String = prep.surgery_state_summary()
			if not strategy_status.is_empty():
				var strategy_label: Label = app.label_at(strategy_status, Vector2(65, 211), 16, Color("9fc9c7"), 650)
				strategy_label.name = "SurgeryStrategyStatus"
			if not prep.active_crisis.is_empty():
				var severity_text: String = app.tx("ui.crisis.severe", "严重") if str(prep.active_crisis.get("severity", "routine")) == "severe" else app.tx("ui.crisis.routine", "常规")
				var crisis_heading: String = app.tx("ui.crisis.heading", "术中生理危机 · %s · 第 %s 次处理") % [severity_text, prep.active_crisis.get("attempt", 1)]
				app.label_at(crisis_heading, Vector2(65, 242), 21, Color("ef9a91"), 650)
				if prep.awaiting_crisis_acknowledgement:
					var crisis_continue: Button = app.button_at(app.tx("ui.crisis.continue", "患者已稳定，继续手术  →"), Vector2(60, 325), Vector2(655, 54), app.preop_event.bind({"kind": "crisis_acknowledge"}))
					crisis_continue.name = "CrisisContinue"
					emphasize_flow_button(app, crisis_continue)
				else:
					action_y = 290
					action_spacing = 62
					for option in prep.crisis_rescue_options():
						var rescue_chance: int = prep.crisis_rescue_chance(str(option.id))
						var rescue_label: String = app.tx("ui.crisis.option", "%s　%s%%　·　+%s分钟") % [option.label, rescue_chance, option.minutes]
						var rescue_button: Button = app.button_at(rescue_label, Vector2(60, action_y), Vector2(655, 54), app.preop_event.bind({"kind": "crisis_rescue", "id": option.id}))
						rescue_button.name = "CrisisRescue_" + str(option.id)
						emphasize_flow_button(app, rescue_button)
						action_y += action_spacing
			elif prep.awaiting_patient_choice:
				metric(app, app.tx("ui.auto.b026d89cdd27", "恐惧"), prep.fear, Vector2(65, 237), Color("d47f79"))
				metric(app, app.tx("ui.auto.508510701136", "痛苦"), prep.pain, Vector2(380, 237), Color("d6a06c"))
				metric(app, app.tx("ui.auto.1147ce7d901f", "尊严"), prep.dignity, Vector2(65, 272), Color("79a9c9"))
				metric(app, app.tx("ui.auto.caf567d6a006", "配合"), prep.cooperation_value(), Vector2(380, 272), Color("7eb696"))
				action_y = 310
				action_spacing = 58
				for action in prep.active_patient_interaction.get("actions", []):
					var patient_action: Button = app.button_at(action.label, Vector2(60, action_y), Vector2(655, 50), app.preop_event.bind({"kind": "patient_interaction_action", "id": action.id}))
					patient_action.name = "PatientInteraction_" + action.id
					emphasize_flow_button(app, patient_action)
					action_y += action_spacing
			elif prep.awaiting_patient_acknowledgement:
				var transition_prompt: String = app.tx("ui.auto.2c23c06dc24f", "先确认患者的这次回应，再进入下一项操作。") if prep.feedback_speaker == "patient" else app.tx("ui.auto.f9c3d4bcb60a", "确认团队成员的处理，再进入下一项操作。") if prep.feedback_speaker == "staff" else app.tx("ui.auto.75c84a2d5594", "确认本阶段记录，再进入下一项操作。")
				app.label_at(transition_prompt, Vector2(65, 245), 20, Color("e1e4db"), 650)
				var patient_continue: Button = app.button_at(app.tx("ui.auto.5e5cf1007ce9", "继续下一步手术"), Vector2(60, 325), Vector2(655, 54), app.preop_event.bind({"kind": "patient_acknowledge"}))
				patient_continue.name = "SurgeryPatientContinue"
				emphasize_flow_button(app, patient_continue)
			elif prep.awaiting_flow_acknowledgement:
				var flow_response_prompt: String = app.tx("ui.auto.98c42815a076", "助手指出选择有误。确认后返回本步骤重新选择。") if prep.pending_flow_retry else app.tx("ui.auto.8c0fa2dea123", "团队成员已经回应。确认后再进入下一段操作。")
				app.label_at(flow_response_prompt, Vector2(65, 245), 20, Color("e1e4db"), 650)
				var flow_continue_label: String = app.tx("ui.auto.ac9f94f535d5", "返回本步骤重新选择") if prep.pending_flow_retry else app.tx("ui.auto.e5746aa27be6", "继续手术")
				var continue_button: Button = app.button_at(flow_continue_label, Vector2(60, 325), Vector2(655, 54), app.preop_event.bind({"kind": "flow_acknowledge"}))
				continue_button.name = "SurgeryFlowContinue"
				emphasize_flow_button(app, continue_button)
			else:
				var transition_text := str(flow_step.get("transition_text", ""))
				if not transition_text.is_empty():
					app.label_at(transition_text, Vector2(65, 239), 14, Color("9fc9c7"), 650)
				app.label_at(str(flow_step.get("prompt", "")), Vector2(65, 270 if not transition_text.is_empty() else 242), 20, Color("e1e4db"), 650)
				action_y = 340 if not transition_text.is_empty() else 315
				action_spacing = 62
				for option in flow_step.get("options", []):
					var flow_button: Button = app.button_at(option.label, Vector2(60, action_y), Vector2(655, 54), app.preop_event.bind({"kind": "surgery_step", "id": option.id}))
					flow_button.name = "SurgeryStep_" + option.id
					emphasize_flow_button(app, flow_button)
					action_y += action_spacing
			action_y = 900
		"complete":
			app.label_at(app.tx("ui.auto.03f556d659aa", "✓ 术前确认完成"), Vector2(65, 235), 32, Color("e8cfaa"), 650)
			app.label_at(app.tx("ui.auto.1e84cb37b69d", "手术还未开始。\n可以保存，下次接着体验术中互动。"), Vector2(65, 304), 23, Color("e1e4db"), 650)
			app.button_at(app.tx("ui.auto.b080ed2dfa2f", "返回医院导览"), Vector2(60, 430), Vector2(655, 54), app.show_map)
		"surgery_complete":
			app.label_at(app.tx("ui.auto.db312ff6f2f4", "✓ 手术成功 · 互动阶段结束"), Vector2(65, 205), 30, Color("e8cfaa"), 650)
			var summary: Label = app.label_at(prep.interaction_summary(), Vector2(65, 255), 19, Color("e1e4db"), 645)
			summary.name = "SurgeryResultSummary"
			summary.size.y = 140
			var time_breakdown: String = app.tx("ui.surgery.settlement_time", "手术耗时 %s　·　术后交接与整理 %s　·　本次合计 %s") % [prep.duration_text(prep.procedure_total_minutes()), prep.duration_text(prep.POSTOPERATIVE_WRAP_UP_MINUTES), prep.duration_text(prep.surgery_settlement_total_minutes())]
			var time_label: Label = app.label_at(time_breakdown, Vector2(65, 402), 20, Color("e8cfaa"), 645)
			time_label.name = "SurgerySettlementTime"
			if prep.pilot_surgery():
				var quality_label: Label = app.label_at(("Surgical Quality: %s (%s)" if prep.english_mode() else "手术质量 Surgical Quality：%s（%s分）") % [prep.surgical_quality_grade(), prep.surgical_quality_score()], Vector2(65, 438), 20, Color("e8cfaa"), 645)
				quality_label.name = "SurgicalQualityResult"
			if not prep.surgery_state_summary().is_empty():
				var strategy_result: Label = app.label_at(prep.surgery_state_summary(), Vector2(65, 470), 17, Color("9fc9c7"), 645)
				strategy_result.name = "SurgeryStrategyResult"
			var metrics: Label = app.label_at(app.tx("ui.auto.21715e65478b", "恐惧 %s　痛苦 %s　尊严 %s　配合 %s") % [prep.fear, prep.pain, prep.dignity, prep.cooperation_value()], Vector2(65, 505), 19, Color("c2d2cc"), 645)
			metrics.name = "SurgeryResultMetrics"
			var return_button: Button = app.button_at(app.tx("ui.auto.fb28c027242c", "结算患者并返回医院导览"), Vector2(60, 520), Vector2(655, 54), app.finish_surgery_and_return)
			return_button.name = "SurgeryResultReturn"
			action_y = 900
		"surgery_abort":
			app.label_at(app.tx("ui.crisis.abort_title", "手术中止 · 患者已由追加支援稳定"), Vector2(65, 205), 29, Color("ef9a91"), 650)
			app.label_at(str(stage.prompt), Vector2(65, 265), 21, Color("e1e4db"), 650)
			var abort_summary: String = app.tx("ui.crisis.abort_summary", "本次术式不计完成次数，不获得手术经验或解锁进度。患者存活并转入后续稳定与观察。")
			app.label_at(abort_summary, Vector2(65, 355), 19, Color("c2d2cc"), 650)
			app.button_at(app.tx("ui.crisis.abort_return", "结束本次手术并返回医院  →"), Vector2(60, 455), Vector2(655, 54), app.finish_aborted_surgery_and_return).name = "SurgeryAbortReturn"
			action_y = 900
		_:
			if prep.flags.has("patient_prepared") and stage.scene == "ward":
				var lines: Array[String] = []
				for id in prep.selected_preparations:
					lines.append(prep.preparation(id).response)
				app.label_at("\n".join(lines), Vector2(65, 195), 20, Color("e8cfaa"), 645)
				app.label_at(app.tx("ui.auto.7a75052c625e", "下一步：更衣 → 刷手 → 进入手术室"), Vector2(65, 280), 22, Color("e8cfaa"), 645)
				action_y = 340
	var action_index := 0
	for action in stage.actions:
		if not prep.action_visible(action):
			continue
		if prep.done.has(action.id):
			continue
		var reason: String = prep.action_reason(action)
		var action_position := Vector2(60, action_y + action_index * action_spacing)
		var action_size := Vector2(655, 50 if stage.kind == "interaction" else 54)
		if stage.kind == "preparation":
			if preparation_sweep_id.is_empty():
				action_position = Vector2(60 + (action_index % 2) * 332, action_y + (action_index / 2) * 62)
				action_size = Vector2(323, 54)
			else:
				action_position = Vector2(60 + action_index * 220, action_y)
				action_size = Vector2(211, 54)
		var button: Button = app.button_at(action.label, action_position, action_size, app.preop_event.bind({"kind": "action", "id": action.id}))
		button.name = "PreopAction_" + action.id
		button.disabled = not reason.is_empty()
		button.tooltip_text = reason
		button.add_theme_stylebox_override("disabled", app.panel_style(Color("24343b")))
		button.add_theme_color_override("font_disabled_color", Color("a0b1b5"))
		action_index += 1
	if not preparation_sweep_id.is_empty():
		var early_sweep_button: Button = app.button_at(app.tx("ui.surgery.sweep", "一键扫荡"), Vector2(500, action_y), Vector2(215, 54), app.sweep_surgery.bind(preparation_sweep_id))
		early_sweep_button.name = "ProcedureSweep_" + preparation_sweep_id
		early_sweep_button.disabled = not prep.sweep_team_ready()
		early_sweep_button.tooltip_text = app.tx("ui.surgery.sweep_ready_hint", "选齐手术团队和病房准备护士后，立即完成已成功做过的术式。")
		early_sweep_button.add_theme_stylebox_override("disabled", app.panel_style(Color("24343b")))
		early_sweep_button.add_theme_color_override("font_disabled_color", Color("a0b1b5"))
	UI.panel(app, Vector2(55, 558), Vector2(1170, 142))
	var note_name: String = app.tx("ui.auto.4d549b32477a", "术中记录") if stage.kind == "surgery_flow" else app.tx("ui.auto.77a3ebc10ddf", "互动记录") if stage.kind in ["interaction", "surgery_complete"] else app.tx("ui.auto.159ea794a181", "术前记事")
	var speaker_name: String = speaking_staff.name if not speaking_staff.is_empty() else prep.crisis_callout_speaker_name() if not prep.active_crisis.is_empty() and prep.feedback_speaker == "staff" else patient.name if prep.feedback_speaker == "patient" or stage.speaker == "patient" else note_name
	var record_speaker: Label = app.label_at(speaker_name, Vector2(82, 570), 20, Color("e8cfaa"), 1100)
	record_speaker.name = "PreopRecordSpeaker"
	var choosing_flow_option: bool = stage.kind == "surgery_flow" and prep.active_crisis.is_empty() and not prep.awaiting_flow_acknowledgement and not prep.awaiting_patient_choice and not prep.awaiting_patient_acknowledgement
	var default_prompt: String = str(flow_step.get("prompt", stage.prompt))
	var text: String = "" if choosing_flow_option else default_prompt if prep.feedback.is_empty() else prep.feedback
	if not speaking_staff.is_empty() and text.begins_with(speaking_staff.name + "："):
		text = text.substr((speaking_staff.name + "：").length())
	elif not prep.feedback.is_empty() and prep.feedback_speaker == "player":
		text = app.protagonist_name() + "：" + text
	var record_font_size := 18 if text.length() > 110 else 20 if text.length() > 65 else 22
	var record_name := "GraphicPreopDialogueText" if stage.kind == "graphic_preop_dialogue" else "PreopRecordText"
	app.scrollable_text_at(text.replace("{patient}", patient.name), Vector2(82, 600), Vector2(1100, 90), record_font_size, Color("f4f0e6"), record_name)
	var save_button: Button = app.button_at(app.tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(60, 713), Vector2(120, 40), app.save_progress)
	if not app.game.can_save_progress():
		save_button.disabled = true
		save_button.tooltip_text = app.game.save_block_reason()
	app.button_at(app.tx("ui.auto.cdee65fb906e", "读档"), Vector2(194, 713), Vector2(120, 40), app.request_load)
	app.label_at(app.tx("ui.auto.dc0675ddad6a", "场景占位 · 本段用时 %s 分钟") % prep.minutes, Vector2(795, 723), 16, Color("c2d2cc"), 420)

static func render_or_table_palpation(app: Control, prep: RefCounted, patient: Dictionary) -> void:
	app.screen = "or_table_palpation"
	var sensory_test: bool = str(prep.current().get("kind", "")) == "anesthesia_sensory_test"
	var title: String
	var subtitle: String
	if sensory_test:
		title = str(app.tx("ui.anesthesia_test.title", "麻醉感觉测试"))
		subtitle = str(app.tx("ui.anesthesia_test.subtitle", "%s / 局麻或硬膜外麻醉后") % patient.name)
	else:
		title = str(app.tx("ui.or_palpation.title", "手术台术前触诊"))
		subtitle = str(app.tx("ui.or_palpation.subtitle", "%s / 麻醉选择前") % patient.name)
	app.base(title, subtitle, false, "operating_room")
	var image_rect: Rect2 = Rect2(330, 68, 620, 626)
	var image_panel: Panel = UI.panel(app, image_rect.position - Vector2(4, 4), image_rect.size + Vector2(8, 8))
	image_panel.name = "PalpationImageFrame"
	var body_image: TextureRect = TextureRect.new()
	body_image.name = "PalpationBodyImage"
	body_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	body_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	body_image.custom_minimum_size = Vector2.ZERO
	var palpation_cg_id := str(prep.or_table_palpation_cg_id)
	var palpation_cg_path: String = str(OR_TABLE_PALPATION_IMAGES.get(palpation_cg_id, OR_TABLE_PALPATION_IMAGES.prototype_v1))
	body_image.texture = load(palpation_cg_path)
	body_image.position = image_rect.position
	body_image.size = image_rect.size
	body_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app.page.add_child(body_image)

	var instruction: String
	if sensory_test:
		instruction = str(app.tx("ui.anesthesia_test.instruction", "选择工具，再点击身体区域确认感觉。\n测试可随时跳过，不会改变麻醉效果。"))
	else:
		instruction = str(app.tx("ui.or_palpation.instruction", "选择工具和力度，再点击身体区域。\n触诊可以跳过；每次操作会累积患者反应。"))
	app.label_at(instruction, Vector2(55, 158), 17, Color("e1e4db"), 245)
	app.label_at(app.tx("ui.or_palpation.tools", "检查工具"), Vector2(55, 235), 20, Color("e8cfaa"), 245)
	var tools: Array = [
		{"id": "palpation", "label": app.tx("ui.or_palpation.hand", "手"), "icon": app.OR_TABLE_HAND_CURSOR_PATH},
		{"id": "needle", "label": app.tx("ui.or_palpation.needle", "针"), "icon": app.OR_TABLE_NEEDLE_CURSOR_PATH},
		{"id": "scalpel", "label": app.tx("ui.or_palpation.scalpel", "手术刀"), "icon": app.OR_TABLE_SCALPEL_CURSOR_PATH},
	]
	for i in range(tools.size()):
		var tool: Dictionary = tools[i]
		var selected: bool = str(app.or_table_palpation_tool) == str(tool.id)
		var prefix: String = "●  " if selected else "○  "
		var tool_button: Button = app.button_at(prefix + str(tool.label), Vector2(55, 270 + i * 58), Vector2(245, 50), app.set_or_table_palpation_tool.bind(str(tool.id)))
		tool_button.name = "PalpationTool_" + ("hand" if str(tool.id) == "palpation" else str(tool.id))
		tool_button.icon = load(str(tool.icon))
		tool_button.expand_icon = true
		if selected:
			var selected_color := Color("653d43") if str(tool.id) == "scalpel" else Color("365963")
			tool_button.add_theme_stylebox_override("normal", app.panel_style(selected_color, Color("e8cfaa")))

	if str(app.or_table_palpation_tool) == "palpation" and not sensory_test:
		app.label_at(app.tx("ui.or_palpation.strength", "触诊力度"), Vector2(55, 452), 20, Color("e8cfaa"), 245)
		var intensities: Array = [
			{"id": "light", "label": app.tx("ui.or_palpation.light", "轻触")},
			{"id": "standard", "label": app.tx("ui.or_palpation.standard", "常规")},
			{"id": "deep", "label": app.tx("ui.or_palpation.deep", "深压")},
		]
		for i in range(intensities.size()):
			var intensity: Dictionary = intensities[i]
			var selected: bool = str(app.or_table_palpation_intensity) == str(intensity.id)
			var prefix: String = "● " if selected else "○ "
			var strength_button: Button = app.button_at(prefix + str(intensity.label), Vector2(55 + i * 82, 487), Vector2(76, 48), app.set_or_table_palpation_intensity.bind(str(intensity.id)))
			strength_button.name = "PalpationStrength_" + str(intensity.id)
			if selected:
				strength_button.add_theme_stylebox_override("normal", app.panel_style(Color("365963"), Color("e8cfaa")))
	elif str(app.or_table_palpation_tool) == "needle":
		var needle_note: String
		if sensory_test:
			needle_note = str(app.tx("ui.anesthesia_test.needle_note", "标准针刺测试：覆盖区保留触压感，但锐痛被阻断。"))
		else:
			needle_note = str(app.tx("ui.or_palpation.needle_warning", "针刺不是常规触诊，不产生检查发现，并会累积负面反应。"))
		app.label_at(needle_note, Vector2(55, 452), 16, Color("e9cfaa"), 245)
	else:
		var scalpel_note: String
		if sensory_test:
			scalpel_note = str(app.tx("ui.anesthesia_test.scalpel_warning", "下刀会立即结束测试；术区尚未消毒。"))
		else:
			scalpel_note = str(app.tx("ui.or_palpation.scalpel_warning", "手术刀已选中。点击身体会立即下刀。"))
		app.label_at(scalpel_note, Vector2(55, 452), 16, Color("e9b3aa"), 245)

	var metrics_panel: Panel = UI.panel(app, Vector2(975, 155), Vector2(250, 182))
	metrics_panel.name = "PalpationMetricsPanel"
	app.label_at(app.tx("ui.or_palpation.patient_state", "患者状态"), Vector2(995, 172), 20, Color("e8cfaa"), 210)
	app.label_at(app.tx("ui.or_palpation.metrics", "恐惧 %s\n痛苦 %s\n尊严 %s\n配合 %s") % [prep.fear, prep.pain, prep.dignity, prep.cooperation_value()], Vector2(995, 211), 20, Color("f4f0e6"), 210)
	app.label_at(app.tx("ui.or_palpation.pending_xp", "待结算手术经验 +%s") % prep.sensory_interaction_xp_bonus, Vector2(995, 307), 15, Color("9ee2c8"), 210)

	var feedback_panel: Panel = UI.panel(app, Vector2(975, 355), Vector2(250, 230))
	feedback_panel.name = "PalpationFeedbackPanel"
	var record_label: String
	if sensory_test:
		record_label = str(app.tx("ui.anesthesia_test.record", "测试记录"))
	else:
		record_label = str(app.tx("ui.or_palpation.record", "触诊记录"))
	var feedback_speaker: String = str(patient.name) if prep.feedback_speaker == "patient" else str(record_label)
	app.label_at(feedback_speaker, Vector2(995, 372), 20, Color("e8cfaa"), 210)
	var response: String = str(prep.feedback)
	if response.is_empty():
		response = app.tx("ui.anesthesia_test.waiting", "患者等待你确认麻醉覆盖，也可以直接跳过。") if sensory_test else app.tx("ui.or_palpation.waiting", "患者仰卧在手术台上；你也可以直接跳过触诊。")
	var feedback_height := 122.0 if not str(prep.last_palpation_confirmation).is_empty() and not sensory_test else 150.0
	app.scrollable_text_at(response, Vector2(995, 412), Vector2(205, feedback_height), 19, Color("f4f0e6"), "PalpationFeedbackText")
	if not sensory_test and not str(prep.last_palpation_confirmation).is_empty():
		var confirmation: Label = app.label_at(app.tx("ui.or_palpation.confirmed", "术区反应已确认"), Vector2(995, 548), 17, Color("9ee2c8"), 210)
		confirmation.name = "PalpationFindingConfirmed"

	if str(app.or_table_palpation_tool) == "scalpel":
		add_palpation_hotspot(app, image_rect, "body", app.tx("ui.or_palpation.scalpel_surface", "用手术刀触碰身体"))
	var hotspot_layout := palpation_hotspot_layout(palpation_cg_id, image_rect)
	var hotspot_tooltips := {
		"breast": [app.tx("ui.or_palpation.region.left_breast", "左乳房"), app.tx("ui.or_palpation.region.right_breast", "右乳房")],
		"nipple": [app.tx("ui.or_palpation.region.left_nipple", "左乳头"), app.tx("ui.or_palpation.region.right_nipple", "右乳头")],
		"chest": [app.tx("ui.or_palpation.region.chest", "胸部／胸骨区")],
		"abdomen": [app.tx("ui.or_palpation.region.abdomen", "腹部")],
		"genital": [app.tx("ui.or_palpation.region.genital", "阴部")],
	}
	for region in ["breast", "nipple", "chest", "abdomen", "genital"]:
		var region_rects: Array = hotspot_layout.get(region, [])
		var region_tooltips: Array = hotspot_tooltips.get(region, [])
		for index in range(region_rects.size()):
			add_palpation_hotspot(app, region_rects[index], region, str(region_tooltips[min(index, region_tooltips.size() - 1)]), str(index))

	var complete_label: String
	if sensory_test:
		complete_label = str(app.tx("ui.anesthesia_test.complete", "完成或跳过测试  →"))
	else:
		complete_label = str(app.tx("ui.or_palpation.complete", "完成或跳过触诊  →"))
	var complete_kind := "anesthesia_sensory_test_complete" if sensory_test else "or_table_palpation_complete"
	var complete_button: Button = app.button_at(complete_label, Vector2(55, 635), Vector2(245, 58), app.preop_event.bind({"kind": complete_kind}))
	complete_button.name = "AnesthesiaTestComplete" if sensory_test else "PalpationComplete"
	var save_button: Button = app.button_at(app.tx("ui.auto.fadf24dbc5a9", "保存"), Vector2(990, 650), Vector2(105, 42), app.save_progress)
	if not app.game.can_save_progress():
		save_button.disabled = true
		save_button.tooltip_text = app.game.save_block_reason()
	app.button_at(app.tx("ui.auto.cdee65fb906e", "读档"), Vector2(1110, 650), Vector2(105, 42), app.request_load)

static func palpation_hotspot_layout(cg_id: String, image_rect: Rect2) -> Dictionary:
	var source_layout: Dictionary = OR_TABLE_PALPATION_HOTSPOTS.get(cg_id, OR_TABLE_PALPATION_HOTSPOTS.prototype_v1)
	var scale := image_rect.size / OR_TABLE_PALPATION_HOTSPOT_REFERENCE_SIZE
	var result := {}
	for region in source_layout:
		var scaled_rects: Array[Rect2] = []
		for source_rect: Rect2 in source_layout[region]:
			scaled_rects.append(Rect2(image_rect.position + source_rect.position * scale, source_rect.size * scale))
		result[region] = scaled_rects
	return result

static func add_palpation_hotspot(app: Control, rect: Rect2, region: String, tooltip: String, slot: String = "0") -> void:
	var hotspot: Button = app.button_at("", rect.position, rect.size, app.or_table_palpation_click.bind(region))
	hotspot.name = "PalpationHotspot_" + region + "_" + slot
	hotspot.tooltip_text = tooltip
	hotspot.mouse_default_cursor_shape = Control.CURSOR_ARROW
	hotspot.mouse_entered.connect(app.apply_or_table_tool_cursor)
	hotspot.mouse_exited.connect(app.clear_or_table_scalpel_cursor.bind(false))
	hotspot.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
	hotspot.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	hotspot.add_theme_stylebox_override("hover", app.panel_style(Color(0.35, 0.75, 0.72, 0.18), Color(0.75, 0.94, 0.91, 0.72)))
	hotspot.add_theme_stylebox_override("pressed", app.panel_style(Color(0.74, 0.46, 0.50, 0.25), Color(0.95, 0.82, 0.68, 0.9)))

static func operative_field_overlay_pool(prep: RefCounted) -> Array:
	var surgery: Dictionary = prep.current_surgery()
	var procedure_key := "procedure:" + str(surgery.get("id", ""))
	if OPERATIVE_FIELD_OVERLAY_POOLS.has(procedure_key):
		return OPERATIVE_FIELD_OVERLAY_POOLS[procedure_key]
	var group_key := "group:" + str(surgery.get("procedure_group", ""))
	return OPERATIVE_FIELD_OVERLAY_POOLS.get(group_key, [])

static func operative_field_overlay_visible(prep: RefCounted, stage: Dictionary, flow_step: Dictionary) -> bool:
	if stage.get("scene", "") != "operating_room":
		return false
	if not prep.flags.has("incision_made"):
		return false
	if operative_field_overlay_pool(prep).is_empty():
		return false
	# General anesthesia has one short post-incision confirmation screen before
	# the authored surgery flow begins. The field should already be visible there.
	if str(stage.get("id", "")) == "general_operation":
		return true
	if stage.get("kind", "") != "surgery_flow":
		return false
	var patient_cues: Array = flow_step.get("patient_cues", [])
	return str(flow_step.get("awake_interlude", "")) != "closure_interaction" and not patient_cues.has("closure")

static func operative_field_overlay_path(prep: RefCounted) -> String:
	# The operative-team background is randomized when the incision event is
	# recorded and survives save/replay. Deriving the overlay from that choice
	# keeps one randomly selected field for the whole operation instead of
	# changing it whenever the page is rendered again.
	var pool := operative_field_overlay_pool(prep)
	if pool.is_empty():
		return ""
	var stable_key := str(prep.operative_background_id)
	var random_background_number := stable_key.right(2).to_int()
	var index := posmod(random_background_number, pool.size())
	return str(pool[index])

static func add_operative_field_overlay(app: Control, prep: RefCounted) -> void:
	var texture := load(operative_field_overlay_path(prep)) as Texture2D
	if texture == null:
		return
	var overlay := TextureRect.new()
	overlay.name = "OperativeFieldOverlay"
	overlay.texture = texture
	overlay.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	overlay.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.modulate = Color(1.0, 1.0, 1.0, 0.94)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app.page.add_child(overlay)
	# Keep the operative-team CG beneath this layer and the common wash, labels,
	# interaction controls, and character portraits above it.
	app.page.move_child(overlay, 1)

static func add_operative_field_hud(app: Control, prep: RefCounted) -> void:
	var texture := load(operative_field_overlay_path(prep)) as Texture2D
	if texture == null:
		return
	var frame := UI.panel(app, Vector2(866, 160), Vector2(348, 184))
	frame.name = "OperativeFieldHUDFrame"
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var field_image := TextureRect.new()
	field_image.name = "OperativeFieldHUD"
	field_image.texture = texture
	field_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	field_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	field_image.position = Vector2(874, 168)
	field_image.size = Vector2(332, 168)
	field_image.mouse_filter = Control.MOUSE_FILTER_IGNORE
	app.page.add_child(field_image)
	var tag: Label = app.label_at(app.tx("ui.surgery.operative_field_hud", "术野"), Vector2(886, 177), 15, Color("f4f0e6"), 80)
	tag.name = "OperativeFieldHUDLabel"

static func operating_room_outfit(staff: Dictionary) -> String:
	# Sterile gown art is a separate outfit. Scrubs remain available for a future
	# circulating-nurse distinction and as a safe fallback for older save data.
	var portraits: Dictionary = staff.get("visuals", {}).get("portraits", {})
	return "sterile" if portraits.has("sterile/focused") else "scrubs"

static func operating_table_outfit(prep: RefCounted, patient: Dictionary, expression: String) -> String:
	# Position-specific operating-table images are interface portraits, not event
	# CGs. Missing expressions deliberately fall back to the existing supine set
	# so patient bundles can be upgraded one complete set at a time.
	var positioning: Dictionary = prep.current_surgery().get("positioning", {})
	if str(positioning.get("primary_position", "supine")) == "lithotomy":
		var lithotomy_outfit := "operating_table_lithotomy"
		var portraits: Dictionary = patient.get("visuals", {}).get("portraits", {})
		if portraits.has(lithotomy_outfit + "/" + expression):
			return lithotomy_outfit
	return "operating_table"

static func intraoperative_patient_expression(prep: RefCounted) -> String:
	if prep.flags.has("anesthetized"):
		return "anesthetized"
	if prep.flags.has("no_anesthesia_confirmed") or prep.anesthesia == "未麻醉": # localization-invariant: authored state ID
		var flow: Array = prep.surgery_flow_steps()
		var collapse_from_step := maxi(1, flow.size() - 2)
		if not flow.is_empty() and prep.procedure_step_index >= collapse_from_step:
			return "near_collapse"
		return "pain"
	return "tense"

static func manual_ward_examination_portrait(prep: RefCounted, stage: Dictionary) -> bool:
	return stage.get("scene", "") == "ward" and prep.flags.has("manual_ward_preparation") and not prep.flags.has("manual_ward_preparation_complete")

static func emphasize_flow_button(app: Control, button: Button) -> void:
	button.add_theme_stylebox_override("normal", app.panel_style(Color("12323bed"), Color("87a9ab")))
	button.add_theme_stylebox_override("hover", app.panel_style(Color("1d4a55fa"), Color("d1b989")))
	button.add_theme_stylebox_override("pressed", app.panel_style(Color("0d2932ff"), Color("e8cfaa")))
	button.add_theme_stylebox_override("focus", app.panel_style(Color("173d47f7"), Color("e8cfaa")))
	button.add_theme_color_override("font_color", Color("f7f6ef"))
	button.add_theme_color_override("font_hover_color", Color("ffffff"))
	button.add_theme_font_size_override("font_size", 22)

static func expression_for_patient(prep: RefCounted, stage: Dictionary) -> String:
	if stage.scene == "operating_room":
		if prep.flags.has("anesthetized"):
			return "anesthetized"
		if stage.id == "procedure_mismatch":
			return "afraid"
		if stage.kind in ["interaction", "surgery_flow", "surgery_complete"]:
			# Expressive patients show fear sooner; reserved patients keep a tense
			# face longer. This is visual characterization and changes no mechanics.
			var expression_threshold: int = clampi(70 - int((prep.patient_trait("expressiveness") - 50) * 0.3), 55, 85)
			if prep.fear >= expression_threshold or prep.pain >= expression_threshold or prep.cooperation_value() <= 30:
				return "afraid"
			return "tense" if prep.fear >= 40 else "awake"
		if prep.flags.has("reassured") or prep.anxiety == 0:
			return "awake"
		return "afraid" if prep.anxiety >= 2 else "tense"
	if prep.anxiety >= 3:
		return "crying"
	if prep.anxiety == 2:
		return "worried"
	if prep.anxiety == 1:
		return "brave"
	return "smile"

static func metric(app: Control, label: String, value: int, position: Vector2, color: Color) -> void:
	app.label_at("%s %3d" % [label, value], position, 16, Color("dce5df"), 92)
	var bar := ProgressBar.new()
	bar.position = position + Vector2(92, 2)
	bar.size = Vector2(195, 20)
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color("263b40")
	background.set_corner_radius_all(3)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(3)
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	app.page.add_child(bar)

static func role_picker(app: Control, prep: RefCounted, role: Dictionary, y: int) -> void:
	app.label_at(role.label, Vector2(65, y + 10), 20, Color("e8cfaa"), 190)
	var picker := OptionButton.new()
	picker.name = "Role_" + role.id
	picker.position = Vector2(250, y)
	picker.size = Vector2(464, 50)
	picker.add_item(app.tx("ui.auto.3d372174482a", "请选择（尚未指派）"))
	var people: Array = prep.candidates(role.id)
	var selected_index := 0
	for i in range(people.size()):
		var person: Dictionary = people[i]
		var proficiency := str(person.get("surgery_proficiency", "trained"))
		var warning: String = app.tx("ui.auto.d46b9504fbf8", "　⚠ 手术经验有限") if proficiency in ["novice", "limited"] else ""
		picker.add_item("%s · %s %s%s" % [person.name, person.specialty, person.skills[role.skill], warning])
		var selected: bool = prep.team.get(role.id) == person.id
		if selected:
			selected_index = i + 1
		elif prep.team.values().has(person.id):
			picker.set_item_disabled(i + 1, true)
	# Keep the placeholder enabled while the list is populated. If it is disabled
	# first, Godot auto-selects the first enabled staff member; clicking that same
	# member for the first assignment then emits no selection change and skips the
	# role-CG unlock path. Once a real assignment exists, disable the placeholder.
	picker.select(selected_index)
	if selected_index > 0:
		picker.set_item_disabled(0, true)
	picker.item_selected.connect(func(index: int):
		if index > 0:
			app.preop_event({"kind": "assign", "role": role.id, "staff_id": people[index - 1].id}))
	app.page.add_child(picker)

extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
const PreopView = preload("res://godot/ui/preop_view.gd")
const Store = preload("res://godot/systems/save_store.gd")

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
	var han := RegEx.new()
	han.compile("[一-鿿ぁ-ヿ]")
	for locale in ["zh_CN", "en"]:
		var content = Loader.new()
		expect(content.load_all(locale), "Content load " + locale)
		expect(content.collections.patients.size() == 36, "Expected 36 patients in " + locale)
		var seen_first_lines := {}
		var seen_lithotomy_lines := {}
		var seen_bladder_lines := {}
		var seen_disinfect_breasts_lines := {}
		var seen_disinfect_perineum_lines := {}
		var seen_slow_trace_lines := {}
		var seen_public_lecture_lines := {}
		var seen_nurse_lecture_comments := {}
		var seen_postop_wipe_lines := {}
		var seen_postop_inspect_lines := {}
		var seen_postop_nurse_comments := {}
		var seen_ward_enema_unnecessary := {}
		var seen_ward_skin_unnecessary := {}
		var lithotomy_portrait_switches := 0
		var all_or_nurses := [
			"nurse_haru", "nurse_rin", "nurse_yui", "nurse_ange", "nurse_hiroko",
			"nurse_moe", "nurse_satsuki", "nurse_iwasaki_rumi", "nurse_yoneda_shiori",
			"nurse_sonoda_itsumi", "nurse_kariya_megumi", "nurse_hikami_saeko",
			"patient_chihaya", "guest_mizuho"
		]
		for patient in content.collections.patients:
			var pid := str(patient.id)
			var variants: Array = patient.get("reaction_variants", {}).get("skip_sterile_draping", [])
			var lithotomy_variants: Array = patient.get("reaction_variants", {}).get("operative_positioning_unnecessary_lithotomy", [])
			var bladder_variants: Array = patient.get("reaction_variants", {}).get("manual_catheter_press_bladder", [])
			var breasts_variants: Array = patient.get("reaction_variants", {}).get("excessive_disinfection_breasts", [])
			var perineum_variants: Array = patient.get("reaction_variants", {}).get("excessive_disinfection_perineum", [])
			var trace_variants: Array = patient.get("reaction_variants", {}).get("slow_incision_trace", [])
			var lecture_variants: Array = patient.get("reaction_variants", {}).get("incision_public_lecture", [])
			var postop_wipe_variants: Array = patient.get("reaction_variants", {}).get("postop_bare_sponge_wipe", [])
			var postop_inspect_variants: Array = patient.get("reaction_variants", {}).get("postop_bare_full_inspection", [])
			var ward_enema_unn_variants: Array = patient.get("reaction_variants", {}).get("ward_enema_unnecessary", [])
			var ward_skin_unn_variants: Array = patient.get("reaction_variants", {}).get("ward_skin_prep_unnecessary", [])
			expect(ward_enema_unn_variants.size() == 2 and str(ward_enema_unn_variants[0]) != str(ward_enema_unn_variants[1]), "Expected 2 unique ward_enema_unnecessary variants for " + pid + " (" + locale + ")")
			expect(ward_skin_unn_variants.size() == 2 and str(ward_skin_unn_variants[0]) != str(ward_skin_unn_variants[1]), "Expected 2 unique ward_skin_prep_unnecessary variants for " + pid + " (" + locale + ")")
			expect(variants.size() == 2 and str(variants[0]) != str(variants[1]), "Expected 2 unique skip_sterile_draping variants for " + pid + " (" + locale + ")")
			expect(lithotomy_variants.size() == 2 and str(lithotomy_variants[0]) != str(lithotomy_variants[1]), "Expected 2 unique unnecessary_lithotomy variants for " + pid + " (" + locale + ")")
			expect(bladder_variants.size() == 2 and str(bladder_variants[0]) != str(bladder_variants[1]), "Expected 2 unique manual_catheter_press_bladder variants for " + pid + " (" + locale + ")")
			expect(breasts_variants.size() == 2 and str(breasts_variants[0]) != str(breasts_variants[1]), "Expected 2 unique excessive_disinfection_breasts variants for " + pid + " (" + locale + ")")
			expect(perineum_variants.size() == 2 and str(perineum_variants[0]) != str(perineum_variants[1]), "Expected 2 unique excessive_disinfection_perineum variants for " + pid + " (" + locale + ")")
			expect(trace_variants.size() == 2 and str(trace_variants[0]) != str(trace_variants[1]), "Expected 2 unique slow_incision_trace variants for " + pid + " (" + locale + ")")
			expect(lecture_variants.size() == 2 and str(lecture_variants[0]) != str(lecture_variants[1]), "Expected 2 unique incision_public_lecture variants for " + pid + " (" + locale + ")")
			expect(postop_wipe_variants.size() == 2 and str(postop_wipe_variants[0]) != str(postop_wipe_variants[1]), "Expected 2 unique postop_bare_sponge_wipe variants for " + pid + " (" + locale + ")")
			expect(postop_inspect_variants.size() == 2 and str(postop_inspect_variants[0]) != str(postop_inspect_variants[1]), "Expected 2 unique postop_bare_full_inspection variants for " + pid + " (" + locale + ")")
			if not variants.is_empty():
				seen_first_lines[str(variants[0])] = true
				if locale == "en":
					for line in variants:
						expect(han.search(str(line)) == null, "CJK remained in English skip_sterile_draping for " + pid)
			if not lithotomy_variants.is_empty():
				seen_lithotomy_lines[str(lithotomy_variants[0])] = true
				if locale == "en":
					for line in lithotomy_variants:
						expect(han.search(str(line)) == null, "CJK remained in English unnecessary_lithotomy for " + pid)
			if not bladder_variants.is_empty():
				seen_bladder_lines[str(bladder_variants[0])] = true
				if locale == "en":
					for line in bladder_variants:
						expect(han.search(str(line)) == null, "CJK remained in English manual_catheter_press_bladder for " + pid)
			if not breasts_variants.is_empty():
				seen_disinfect_breasts_lines[str(breasts_variants[0])] = true
				if locale == "en":
					for line in breasts_variants:
						expect(han.search(str(line)) == null, "CJK remained in English excessive_disinfection_breasts for " + pid)
			if not perineum_variants.is_empty():
				seen_disinfect_perineum_lines[str(perineum_variants[0])] = true
				if locale == "en":
					for line in perineum_variants:
						expect(han.search(str(line)) == null, "CJK remained in English excessive_disinfection_perineum for " + pid)
			if not trace_variants.is_empty():
				seen_slow_trace_lines[str(trace_variants[0])] = true
				if locale == "en":
					for line in trace_variants:
						expect(han.search(str(line)) == null, "CJK remained in English slow_incision_trace for " + pid)
			if not lecture_variants.is_empty():
				seen_public_lecture_lines[str(lecture_variants[0])] = true
				if locale == "en":
					for line in lecture_variants:
						expect(han.search(str(line)) == null, "CJK remained in English incision_public_lecture for " + pid)
			if not postop_wipe_variants.is_empty():
				seen_postop_wipe_lines[str(postop_wipe_variants[0])] = true
				if locale == "en":
					for line in postop_wipe_variants:
						expect(han.search(str(line)) == null, "CJK remained in English postop_bare_sponge_wipe for " + pid)
			if not postop_inspect_variants.is_empty():
				seen_postop_inspect_lines[str(postop_inspect_variants[0])] = true
				if locale == "en":
					for line in postop_inspect_variants:
						expect(han.search(str(line)) == null, "CJK remained in English postop_bare_full_inspection for " + pid)
			if not ward_enema_unn_variants.is_empty():
				seen_ward_enema_unnecessary[str(ward_enema_unn_variants[0])] = true
				for line in ward_enema_unn_variants:
					if locale == "zh_CN":
						expect(not str(line).contains("太好了") and not str(line).contains("逃过一劫"), "No backwards skipped-relief wording in ward_enema_unnecessary for " + pid)
					else:
						expect(han.search(str(line)) == null, "CJK remained in English ward_enema_unnecessary for " + pid)
			if not ward_skin_unn_variants.is_empty():
				seen_ward_skin_unnecessary[str(ward_skin_unn_variants[0])] = true
				for line in ward_skin_unn_variants:
					if locale == "zh_CN":
						expect(not str(line).contains("太好了") and not str(line).contains("逃过一劫"), "No backwards skipped-relief wording in ward_skin_prep_unnecessary for " + pid)
					else:
						expect(han.search(str(line)) == null, "CJK remained in English ward_skin_prep_unnecessary for " + pid)

			var preop_def: Dictionary = content.find_record("preops", "preop_" + pid.trim_prefix("patient_")).duplicate(true)
			preop_def["_locale"] = locale

			# 1. General anesthesia hides skip_sterile_draping.
			var gen_prep = Preop.new(preop_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			gen_prep.stage_id = "ready"
			expect(gen_prep.apply({"kind": "action", "id": "choose_general"}), "Choose general for " + pid)
			expect(gen_prep.apply({"kind": "action", "id": "induction_reassure"}), "Induction for " + pid)
			for step in ["operative_positioning", "ack_positioning", "urinary_catheterization", "ack_catheterization", "skin_disinfection"]:
				expect(gen_prep.apply({"kind": "action", "id": step}), "General step " + step + " for " + pid)
			expect(gen_prep.stage_id == "skin_disinfection_response", "General reached skin_disinfection_response for " + pid)
			var skip_action: Dictionary = {}
			for action in gen_prep.current().actions:
				if str(action.id) == "skip_sterile_draping":
					skip_action = action
			expect(not skip_action.is_empty() and not gen_prep.action_visible(skip_action), "General anesthesia must hide skip_sterile_draping for " + pid)
			expect(not gen_prep.apply({"kind": "action", "id": "skip_sterile_draping"}), "General anesthesia must reject skip_sterile_draping for " + pid)

			# 2. Awake anesthesia exposes skip_sterile_draping and applies exact deltas + dedicated shame line.
			var awake_prep = Preop.new(preop_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			awake_prep.stage_id = "ready"
			expect(awake_prep.apply({"kind": "action", "id": "choose_local"}), "Choose local for " + pid)
			expect(awake_prep.apply({"kind": "anesthesia_sensory_test_complete"}), "Complete sensory test for " + pid)
			for step in ["operative_positioning", "ack_positioning", "urinary_catheterization", "ack_catheterization", "skin_disinfection"]:
				expect(awake_prep.apply({"kind": "action", "id": step}), "Awake step " + step + " for " + pid)
			awake_prep.fear = 40
			awake_prep.pain = 10
			awake_prep.dignity = 80
			awake_prep.cooperation_base = 70
			awake_prep.presence_preop_raw = 2
			awake_prep.presence_or_raw = 0
			awake_prep.player_effects.presence = 2
			expect(awake_prep.apply({"kind": "action", "id": "skip_sterile_draping"}), "Awake skip_sterile_draping accepted for " + pid)
			expect(awake_prep.stage_id == "sterile_draping_skipped_response", "Transitioned to sterile_draping_skipped_response for " + pid)
			expect(awake_prep.flags.has("sterile_draping_skipped"), "Set sterile_draping_skipped flag for " + pid)
			expect(awake_prep.dignity == 55 and awake_prep.fear == 48 and awake_prep.pain == 10 and awake_prep.cooperation_base == 65, "Exact dignity -25, fear +8, cooperation -5 for " + pid)
			expect(awake_prep.presence_or_raw == 1 and awake_prep.player_effects.presence == 3, "Presence +1 scored in OR phase for " + pid)
			expect(awake_prep.feedback_speaker == "patient" and awake_prep.feedback in variants, "Used patient dedicated skip_sterile_draping variant for " + pid)
			expect(awake_prep.apply({"kind": "action", "id": "ack_skip_sterile_draping"}), "Acknowledge skipped draping for " + pid)
			expect(awake_prep.stage_id == "incision_marking" and awake_prep.feedback.is_empty(), "Proceeded cleanly to incision_marking for " + pid)

			# Step 1: Unnecessary lithotomy on supine surgery vs hidden on native lithotomy surgery.
			var litho_prep = Preop.new(preop_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			litho_prep.procedure_id = "surgery_vaginal_hysterectomy"
			litho_prep.refresh_operative_positioning_stage()
			expect(litho_prep.stages.operative_positioning.actions.size() == 1, "Native lithotomy surgery must not offer unnecessary lithotomy for " + pid)
			litho_prep.procedure_id = "surgery_breast_tumor"
			litho_prep.refresh_operative_positioning_stage()
			expect(litho_prep.stages.operative_positioning.actions.size() == 2, "Supine surgery must offer unnecessary lithotomy action for " + pid)
			litho_prep.stage_id = "ready"
			expect(litho_prep.apply({"kind": "action", "id": "choose_local"}), "Choose local for lithotomy test " + pid)
			expect(litho_prep.apply({"kind": "anesthesia_sensory_test_complete"}), "Complete sensory test for lithotomy test " + pid)
			expect(PreopView.operating_table_outfit(litho_prep, patient, "tense") == "operating_table", "Before forced lithotomy uses supine outfit for " + pid)
			litho_prep.fear = 30
			litho_prep.pain = 0
			litho_prep.dignity = 90
			litho_prep.cooperation_base = 75
			litho_prep.presence_preop_raw = 2
			litho_prep.presence_or_raw = 0
			litho_prep.player_effects.presence = 2
			expect(litho_prep.apply({"kind": "action", "id": "operative_positioning_unnecessary_lithotomy"}), "Forced lithotomy accepted for " + pid)
			expect(litho_prep.stage_id == "operative_positioning_response" and litho_prep.flags.has("unnecessary_lithotomy_positioned") and litho_prep.flags.has("operative_positioned"), "Forced lithotomy set flags for " + pid)
			expect(litho_prep.dignity == 70 and litho_prep.fear == 36 and litho_prep.pain == 0 and litho_prep.cooperation_base == 70, "Exact forced lithotomy effects for " + pid)
			expect(litho_prep.presence_or_raw == 1 and litho_prep.player_effects.presence == 3, "Forced lithotomy +1 OR presence for " + pid)
			expect(litho_prep.feedback_speaker == "patient" and litho_prep.feedback in lithotomy_variants, "Forced lithotomy used dedicated patient variant for " + pid)
			var expected_lithotomy_outfit := "operating_table_lithotomy" if patient.get("visuals", {}).get("portraits", {}).has("operating_table_lithotomy/tense") else "operating_table"
			if expected_lithotomy_outfit == "operating_table_lithotomy":
				lithotomy_portrait_switches += 1
			expect(PreopView.operating_table_outfit(litho_prep, patient, "tense") == expected_lithotomy_outfit, "Forced lithotomy switched portrait to operating_table_lithotomy (or safe fallback) for " + pid)

			# Step 2: 4-beat manual catheterization + suprapubic bladder expression + nurse verification.
			var cath_prep = Preop.new(preop_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			var circ_nurse_id: String = str(all_or_nurses[seen_bladder_lines.size() % all_or_nurses.size()])
			cath_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru" if circ_nurse_id != "nurse_haru" else "nurse_rin", "circulating_nurse": circ_nurse_id}
			cath_prep.stage_id = "urinary_catheterization"
			cath_prep.flags.assign(["anesthesia_chosen", "general_anesthesia", "anesthetized", "operative_positioned"])
			expect(not cath_prep.apply({"kind": "action", "id": "begin_manual_catheterization"}), "General anesthesia must reject begin_manual_catheterization for " + pid)
			cath_prep.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "operative_positioned"])
			expect(cath_prep.apply({"kind": "action", "id": "begin_manual_catheterization"}), "Beat 1: begin_manual_catheterization accepted for " + pid)
			expect(cath_prep.stage_id == "manual_catheter_insertion" and cath_prep.feedback_speaker == "staff" and cath_prep.last_staff_id == circ_nurse_id, "Beat 1: circulating nurse spoke for " + pid)
			if locale == "en":
				expect(han.search(cath_prep.feedback) == null, "Beat 1: English nurse response clean for " + circ_nurse_id)
			expect(cath_prep.apply({"kind": "action", "id": "manual_urinary_catheterization"}), "Beat 2: manual_urinary_catheterization accepted for " + pid)
			expect(cath_prep.stage_id == "manual_catheter_bladder_press" and cath_prep.feedback_speaker == "patient", "Beat 2: patient reacted to manual catheter insertion for " + pid)
			expect(cath_prep.feedback in patient.get("reaction_variants", {}).get("urinary_catheterization_awake", []), "Beat 2: used patient catheter insertion variant for " + pid)
			cath_prep.fear = 40
			cath_prep.pain = 10
			cath_prep.dignity = 80
			cath_prep.cooperation_base = 70
			cath_prep.presence_preop_raw = 2
			cath_prep.presence_or_raw = 0
			cath_prep.player_effects.presence = 2
			expect(cath_prep.apply({"kind": "action", "id": "manual_catheter_press_bladder"}), "Beat 3: manual_catheter_press_bladder accepted for " + pid)
			expect(cath_prep.stage_id == "manual_catheter_press_response" and cath_prep.flags.has("manual_bladder_pressed"), "Beat 3: entered manual_catheter_press_response for " + pid)
			expect(cath_prep.dignity == 58 and cath_prep.fear == 47 and cath_prep.pain == 13 and cath_prep.cooperation_base == 65, "Beat 3: exact dignity -22, fear +7, pain +3, cooperation -5 for " + pid)
			expect(cath_prep.presence_or_raw == 1 and cath_prep.player_effects.presence == 3, "Beat 3: +1 OR presence for " + pid)
			expect(cath_prep.feedback_speaker == "patient" and cath_prep.feedback in bladder_variants, "Beat 3: used dedicated bladder-press shame line for " + pid)
			expect(cath_prep.apply({"kind": "action", "id": "nurse_verify_catheter_drainage"}), "Beat 4: nurse_verify_catheter_drainage accepted for " + pid)
			expect(cath_prep.stage_id == "urinary_catheterization_response" and cath_prep.feedback_speaker == "staff" and cath_prep.last_staff_id == circ_nurse_id, "Beat 4: circulating nurse verified drainage volume for " + pid)
			if locale == "en":
				expect(han.search(cath_prep.feedback) == null, "Beat 4: English nurse drainage verification clean for " + circ_nurse_id)
			expect(cath_prep.apply({"kind": "action", "id": "ack_catheterization"}) and cath_prep.stage_id == "skin_disinfection", "Beat 4: continued to skin_disinfection for " + pid)

			# Step 3: 4-beat excessive chest-to-perineum disinfection + air-drying bare + nurse confirmation.
			var scrub_nurse_id: String = str(all_or_nurses[(seen_bladder_lines.size() + 3) % all_or_nurses.size()])
			cath_prep.team["scrub_nurse"] = scrub_nurse_id
			cath_prep.flags.assign(["anesthesia_chosen", "general_anesthesia", "anesthetized", "urinary_catheterized"])
			expect(not cath_prep.apply({"kind": "action", "id": "begin_excessive_disinfection"}), "General anesthesia must reject begin_excessive_disinfection for " + pid)
			cath_prep.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "urinary_catheterized"])
			expect(cath_prep.apply({"kind": "action", "id": "begin_excessive_disinfection"}), "Step 3 Beat 1: begin_excessive_disinfection accepted for " + pid)
			expect(cath_prep.stage_id == "excessive_disinfection_breasts" and cath_prep.feedback_speaker == "staff" and cath_prep.last_staff_id == circ_nurse_id, "Step 3 Beat 1: circulating nurse passed forceps for " + pid)
			cath_prep.fear = 30
			cath_prep.pain = 5
			cath_prep.dignity = 80
			cath_prep.cooperation_base = 70
			cath_prep.presence_or_raw = 0
			cath_prep.player_effects.presence = 0
			expect(cath_prep.apply({"kind": "action", "id": "excessive_disinfection_breasts"}), "Step 3 Beat 2: excessive_disinfection_breasts accepted for " + pid)
			expect(cath_prep.stage_id == "excessive_disinfection_perineum" and cath_prep.feedback_speaker == "patient" and cath_prep.feedback in breasts_variants, "Step 3 Beat 2: used dedicated breasts disinfection line for " + pid)
			expect(cath_prep.dignity == 70 and cath_prep.fear == 33 and cath_prep.pain == 5 and cath_prep.cooperation_base == 68, "Step 3 Beat 2: exact breasts deltas for " + pid)
			expect(cath_prep.apply({"kind": "action", "id": "excessive_disinfection_perineum"}), "Step 3 Beat 3: excessive_disinfection_perineum accepted for " + pid)
			expect(cath_prep.stage_id == "excessive_disinfection_drying" and cath_prep.feedback_speaker == "patient" and cath_prep.feedback in perineum_variants, "Step 3 Beat 3: used dedicated perineum disinfection line for " + pid)
			expect(cath_prep.dignity == 52 and cath_prep.fear == 38 and cath_prep.pain == 7 and cath_prep.cooperation_base == 64 and cath_prep.presence_or_raw == 1, "Step 3 Beat 3: exact perineum deltas + OR presence +1 for " + pid)
			expect(cath_prep.apply({"kind": "action", "id": "ack_disinfection_drying"}), "Step 3 Beat 4: ack_disinfection_drying accepted for " + pid)
			expect(cath_prep.stage_id == "skin_disinfection_response" and cath_prep.feedback_speaker == "staff" and cath_prep.last_staff_id == scrub_nurse_id, "Step 3 Beat 4: scrub nurse confirmed air-drying and entered skin_disinfection_response for " + pid)
			if locale == "en":
				expect(han.search(cath_prep.feedback) == null, "Step 3 Beat 4: English scrub nurse air-drying line clean for " + scrub_nurse_id)

			# Step 4: 4-beat slow incision tracing + public body-sign lecture + shared-pool nurse commentary.
			cath_prep.stage_id = "incision_marking"
			cath_prep.flags.assign(["anesthesia_chosen", "general_anesthesia", "anesthetized", "skin_disinfected"])
			expect(not cath_prep.apply({"kind": "action", "id": "begin_slow_incision_marking"}), "General anesthesia must reject begin_slow_incision_marking for " + pid)
			cath_prep.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "skin_disinfected"])
			cath_prep.session_flavor_salt = seen_slow_trace_lines.size() * 97 + 13
			expect(cath_prep.apply({"kind": "action", "id": "begin_slow_incision_marking"}), "Step 4 Beat 1: begin_slow_incision_marking accepted for " + pid)
			expect(cath_prep.stage_id == "slow_incision_tracing" and cath_prep.feedback_speaker == "player", "Step 4 Beat 1: player announced calibration for " + pid)
			cath_prep.fear = 30
			cath_prep.pain = 5
			cath_prep.dignity = 80
			cath_prep.cooperation_base = 70
			cath_prep.presence_or_raw = 0
			cath_prep.player_effects.presence = 0
			expect(cath_prep.apply({"kind": "action", "id": "slow_incision_trace"}), "Step 4 Beat 2: slow_incision_trace accepted for " + pid)
			expect(cath_prep.stage_id == "incision_public_lecture" and cath_prep.flags.has("incision_marked") and cath_prep.flags.has("slow_incision_traced"), "Step 4 Beat 2: entered incision_public_lecture for " + pid)
			expect(cath_prep.feedback_speaker == "patient" and cath_prep.feedback in trace_variants, "Step 4 Beat 2: used dedicated slow_incision_trace fear/shame line for " + pid)
			expect(cath_prep.dignity == 70 and cath_prep.fear == 38 and cath_prep.pain == 5 and cath_prep.cooperation_base == 68 and cath_prep.presence_or_raw == 1, "Step 4 Beat 2: exact slow_incision_trace deltas + OR presence +1 for " + pid)
			expect(cath_prep.apply({"kind": "action", "id": "incision_public_lecture"}), "Step 4 Beat 3: incision_public_lecture accepted for " + pid)
			expect(cath_prep.stage_id == "incision_nurse_commentary" and cath_prep.flags.has("incision_public_lectured"), "Step 4 Beat 3: entered incision_nurse_commentary for " + pid)
			expect(cath_prep.feedback_speaker == "patient" and cath_prep.feedback in lecture_variants, "Step 4 Beat 3: used dedicated incision_public_lecture humiliation line for " + pid)
			expect(cath_prep.dignity == 54 and cath_prep.fear == 43 and cath_prep.pain == 5 and cath_prep.cooperation_base == 65 and cath_prep.presence_or_raw == 1, "Step 4 Beat 3: combined dignity -26, fear +13, cooperation -5, presence +1 for " + pid)
			expect(cath_prep.apply({"kind": "action", "id": "ack_incision_nurse_commentary"}), "Step 4 Beat 4: ack_incision_nurse_commentary accepted for " + pid)
			expect(cath_prep.stage_id == "incision_marking_response" and cath_prep.feedback_speaker == "staff" and cath_prep.last_staff_id == circ_nurse_id, "Step 4 Beat 4: circulating nurse gave random pool commentary and reached incision_marking_response for " + pid)
			seen_nurse_lecture_comments[cath_prep.feedback.get_slice("：", 1)] = true
			if locale == "en":
				expect(han.search(cath_prep.feedback) == null, "Step 4 Beat 4: English nurse commentary clean for " + circ_nurse_id)

			# Step 5: 4-beat postoperative bare saline wipe-down + pre-transfer full-body inspection + nurse cover commentary.
			var postop_prep = Preop.new(preop_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			postop_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": scrub_nurse_id, "circulating_nurse": circ_nurse_id}
			postop_prep.procedure_id = "surgery_breast_tumor"
			postop_prep.procedure_name = "Breast Tumor Excision" if locale == "en" else "乳腺肿物切除术"
			postop_prep.procedure_minutes = 45
			postop_prep.procedure_state = {"progress": 100, "stability": 85, "blood_loss": 10, "elapsed_time": 45, "stress": 2, "bleeding": 0}
			postop_prep.operative_background_id = "or_team_01"
			postop_prep.stage_id = "procedure_execute"
			postop_prep.flags.assign(["anesthesia_chosen", "general_anesthesia", "anesthetized", "incision_made", "interaction_complete"])
			expect(not postop_prep.apply({"kind": "action", "id": "begin_postop_bare_inspection"}), "General anesthesia must reject begin_postop_bare_inspection for " + pid)
			postop_prep.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "incision_made", "interaction_complete"])
			postop_prep.session_flavor_salt = seen_postop_wipe_lines.size() * 131 + 29
			expect(postop_prep.apply({"kind": "action", "id": "begin_postop_bare_inspection"}), "Step 5 Beat 1: begin_postop_bare_inspection accepted for " + pid)
			expect(postop_prep.stage_id == "postop_bare_wipe" and postop_prep.feedback_speaker == "player", "Step 5 Beat 1: entered postop_bare_wipe for " + pid)
			expect(PreopView.intraoperative_patient_expression(postop_prep) == "near_collapse", "Step 5 Beat 1: intraoperative portrait switches to near_collapse for " + pid)
			postop_prep.fear = 45
			postop_prep.pain = 20
			postop_prep.dignity = 60
			postop_prep.lowest_dignity_seen = 60
			postop_prep.cooperation_base = 65
			postop_prep.presence_or_raw = 0
			postop_prep.player_effects.presence = 0
			expect(postop_prep.apply({"kind": "action", "id": "postop_bare_sponge_wipe"}), "Step 5 Beat 2: postop_bare_sponge_wipe accepted for " + pid)
			expect(postop_prep.stage_id == "postop_bare_inspection" and postop_prep.flags.has("postop_bare_wiped"), "Step 5 Beat 2: entered postop_bare_inspection for " + pid)
			expect(postop_prep.feedback_speaker == "patient" and postop_prep.feedback in postop_wipe_variants, "Step 5 Beat 2: used dedicated postop_bare_sponge_wipe despair line for " + pid)
			expect(postop_prep.dignity == 48 and postop_prep.fear == 49 and postop_prep.pain == 22 and postop_prep.cooperation_base == 63 and postop_prep.presence_or_raw == 1, "Step 5 Beat 2: exact sponge-wipe deltas + OR presence +1 for " + pid)
			expect(postop_prep.apply({"kind": "action", "id": "postop_bare_full_inspection"}), "Step 5 Beat 3: postop_bare_full_inspection accepted for " + pid)
			expect(postop_prep.stage_id == "postop_nurse_commentary" and postop_prep.flags.has("postop_bare_inspected") and postop_prep.flags.has("postop_bare_cleanup_done"), "Step 5 Beat 3: entered postop_nurse_commentary for " + pid)
			expect(postop_prep.feedback_speaker == "patient" and postop_prep.feedback in postop_inspect_variants, "Step 5 Beat 3: used dedicated postop_bare_full_inspection despair line for " + pid)
			expect(postop_prep.dignity == 33 and postop_prep.lowest_dignity_seen == 33 and postop_prep.fear == 53 and postop_prep.pain == 22 and postop_prep.cooperation_base == 60 and postop_prep.presence_or_raw == 1, "Step 5 Beat 3: combined dignity -27 recorded in lowest_dignity_seen for " + pid)
			expect(postop_prep.apply({"kind": "action", "id": "ack_postop_nurse_commentary"}), "Step 5 Beat 4: ack_postop_nurse_commentary accepted for " + pid)
			expect(postop_prep.stage_id == "procedure_execute" and postop_prep.feedback_speaker == "staff" and postop_prep.last_staff_id == circ_nurse_id, "Step 5 Beat 4: circulating nurse covered patient and returned to procedure_execute for " + pid)
			seen_postop_nurse_comments[postop_prep.feedback.get_slice("：", 1)] = true
			if locale == "en":
				expect(han.search(postop_prep.feedback) == null, "Step 5 Beat 4: English nurse cover commentary clean for " + circ_nurse_id)
			expect(not postop_prep.action_visible(postop_prep.stages.procedure_execute.actions[1]), "Step 5 Beat 4: mischief button hidden after postop_bare_cleanup_done for " + pid)
			expect(postop_prep.apply({"kind": "action", "id": "execute_confirmed_procedure"}) and postop_prep.surgery_success and postop_prep.stage_id == "surgery_result", "Step 5 Settlement: execute_confirmed_procedure settled to surgery_result for " + pid)

		# Verify all 14 OR nurses + future experienced/novice nurse fallbacks + abdominal vs chest surgery comeback wording.
		for surg_id in ["surgery_appendix", "surgery_breast_tumor"]:
			var nurse_probe_def: Dictionary = content.find_record("preops", "preop_sora").duplicate(true)
			nurse_probe_def["surgery_id"] = surg_id
			nurse_probe_def["_locale"] = locale
			var probe = Preop.new(nurse_probe_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
			probe.roster["future_nurse_exp"] = {"id": "future_nurse_exp", "name": "Future Exp", "profession": "nurse", "surgery_proficiency": "trained"}
			probe.roster["future_nurse_novice"] = {"id": "future_nurse_novice", "name": "Future Nov", "profession": "nurse", "surgery_proficiency": "novice"}
			for nid in all_or_nurses + ["future_nurse_exp", "future_nurse_novice"]:
				var b1: String = probe.manual_catheter_nurse_response(nid, "begin_manual_catheterization")
				var b4: String = probe.manual_catheter_nurse_response(nid, "nurse_verify_catheter_drainage")
				var d1: String = probe.excessive_disinfection_nurse_response(nid, "begin_excessive_disinfection")
				var d4: String = probe.excessive_disinfection_nurse_response(nid, "ack_disinfection_drying")
				expect(not b1.is_empty() and not b4.is_empty() and not d1.is_empty() and not d4.is_empty(), "Non-empty nurse responses for " + nid + " (" + locale + ")")
				if locale == "en":
					expect(han.search(b1 + b4 + d1 + d4) == null, "English nurse responses free of CJK for " + nid)
				if nid == "nurse_ange":
					var expected_cut := ("belly sliced open" if surg_id == "surgery_appendix" else "under the scalpel") if locale == "en" else ("把肚子切开了" if surg_id == "surgery_appendix" else "动刀切开了")
					expect(b4.contains(expected_cut), "Ange sharp-tongued comeback adapts to surgery site (" + surg_id + ", " + locale + ")")

		expect(lithotomy_portrait_switches >= 34, "Expected at least 34 patients to switch to dedicated operating_table_lithotomy portraits in " + locale)
		expect(seen_first_lines.size() == 36, "All 36 patients must have distinct dedicated skip_sterile_draping lines in " + locale)
		expect(seen_lithotomy_lines.size() == 36, "All 36 patients must have distinct dedicated unnecessary_lithotomy lines in " + locale)
		expect(seen_bladder_lines.size() == 36, "All 36 patients must have distinct dedicated manual_catheter_press_bladder lines in " + locale)
		expect(seen_disinfect_breasts_lines.size() == 36, "All 36 patients must have distinct dedicated excessive_disinfection_breasts lines in " + locale)
		expect(seen_disinfect_perineum_lines.size() == 36, "All 36 patients must have distinct dedicated excessive_disinfection_perineum lines in " + locale)
		expect(seen_slow_trace_lines.size() == 36, "All 36 patients must have distinct dedicated slow_incision_trace lines in " + locale)
		expect(seen_public_lecture_lines.size() == 36, "All 36 patients must have distinct dedicated incision_public_lecture lines in " + locale)
		expect(seen_nurse_lecture_comments.size() >= 6, "Shared nurse commentary pool must produce varied remarks across runs in " + locale)
		expect(seen_postop_wipe_lines.size() == 36, "All 36 patients must have distinct dedicated postop_bare_sponge_wipe lines in " + locale)
		expect(seen_postop_inspect_lines.size() == 36, "All 36 patients must have distinct dedicated postop_bare_full_inspection lines in " + locale)
		expect(seen_ward_enema_unnecessary.size() == 36, "All 36 patients must have distinct dedicated ward_enema_unnecessary lines in " + locale)
		expect(seen_ward_skin_unnecessary.size() == 36, "All 36 patients must have distinct dedicated ward_skin_prep_unnecessary lines in " + locale)
		expect(seen_postop_nurse_comments.size() >= 6, "Shared postop nurse commentary pool must produce varied remarks across runs in " + locale)

		# Verify Step 4 early-exit branches and intraoperative low-dignity exposure synergy.
		var synergy_def: Dictionary = content.find_record("preops", "preop_sora").duplicate(true)
		synergy_def["_locale"] = locale
		var early_prep = Preop.new(synergy_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
		early_prep.stage_id = "incision_marking"
		early_prep.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "skin_disinfected"])
		expect(early_prep.apply({"kind": "action", "id": "begin_slow_incision_marking"}) and early_prep.apply({"kind": "action", "id": "finish_incision_marking_normally"}), "Step 4 early exit 1 accepted (" + locale + ")")
		expect(early_prep.stage_id == "incision_marking_response" and early_prep.flags.has("incision_marked") and not early_prep.flags.has("slow_incision_traced"), "Step 4 early exit 1 landed cleanly (" + locale + ")")
		var early_prep2 = Preop.new(synergy_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
		early_prep2.stage_id = "incision_marking"
		early_prep2.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "skin_disinfected"])
		expect(early_prep2.apply({"kind": "action", "id": "begin_slow_incision_marking"}) and early_prep2.apply({"kind": "action", "id": "slow_incision_trace"}) and early_prep2.apply({"kind": "action", "id": "skip_incision_lecture"}), "Step 4 early exit 2 accepted (" + locale + ")")
		expect(early_prep2.stage_id == "incision_marking_response" and early_prep2.flags.has("incision_marked") and not early_prep2.flags.has("incision_public_lectured"), "Step 4 early exit 2 landed cleanly (" + locale + ")")
		early_prep.dignity = 30
		early_prep.cooperation_base = 75
		early_prep.flags.assign(["awake_anesthesia", "local_anesthesia"])
		early_prep.resolved_random_choices["patient_intrusion:step_exp:dignity_intrusion"] = 40
		expect(not early_prep.resolve_patient_intrusion_for_stage({"id": "step_exp", "patient_cues": ["exposure"]}), "Roll 40 does not trigger dignity_intrusion without shame flags (" + locale + ")")
		early_prep.flags.assign(["awake_anesthesia", "local_anesthesia", "sterile_draping_skipped", "incision_public_lectured"])
		expect(early_prep.resolve_patient_intrusion_for_stage({"id": "step_exp", "patient_cues": ["exposure"]}) and early_prep.dignity_intrusion_count == 1, "Roll 40 triggers dignity_intrusion when shame flags stack (" + locale + ")")

		# Verify Step 5 early-exit branches and incomplete strategic surgery guard.
		var postop_early1 = Preop.new(synergy_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
		postop_early1.procedure_id = "surgery_appendix"
		postop_early1.procedure_minutes = 50
		postop_early1.stage_id = "procedure_execute"
		postop_early1.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "incision_made", "interaction_complete"])
		postop_early1.procedure_state = {"progress": 40, "stability": 90}
		expect(not postop_early1.apply({"kind": "action", "id": "begin_postop_bare_inspection"}), "Incomplete strategic surgery must reject begin_postop_bare_inspection (" + locale + ")")
		postop_early1.procedure_state = {"progress": 100, "stability": 90}
		expect(postop_early1.apply({"kind": "action", "id": "begin_postop_bare_inspection"}) and postop_early1.apply({"kind": "action", "id": "finish_postop_cover_sheet"}), "Step 5 early exit 1 accepted (" + locale + ")")
		expect(postop_early1.stage_id == "procedure_execute" and postop_early1.flags.has("postop_bare_cleanup_done") and postop_early1.apply({"kind": "action", "id": "execute_confirmed_procedure"}) and postop_early1.surgery_success, "Step 5 early exit 1 settled cleanly (" + locale + ")")
		var postop_early2 = Preop.new(synergy_def, content.collections.staff, content.collections.surgeries, content.collections.patients)
		postop_early2.procedure_id = "surgery_breast_tumor"
		postop_early2.procedure_minutes = 45
		postop_early2.procedure_state = {"progress": 100, "stability": 90}
		postop_early2.stage_id = "procedure_execute"
		postop_early2.flags.assign(["anesthesia_chosen", "awake_anesthesia", "local_anesthesia", "incision_made", "interaction_complete"])
		expect(postop_early2.apply({"kind": "action", "id": "begin_postop_bare_inspection"}) and postop_early2.apply({"kind": "action", "id": "postop_bare_sponge_wipe"}) and postop_early2.apply({"kind": "action", "id": "skip_postop_inspection"}), "Step 5 early exit 2 accepted (" + locale + ")")
		expect(postop_early2.stage_id == "procedure_execute" and postop_early2.flags.has("postop_bare_cleanup_done") and postop_early2.apply({"kind": "action", "id": "execute_confirmed_procedure"}) and postop_early2.surgery_success, "Step 5 early exit 2 settled cleanly (" + locale + ")")

	# 3. UI check: skipping draping on a patient with a sterile_draping CG must NOT show WardPreparationCG.
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	app.game.patient_cases = app.game.legacy_patient_cases()
	app.game.rebuild_patient_content(app.game.patient_cases)
	var visit = app.game.open_visit("visit_emi")
	visit.admitted = true
	var emi_prep = app.game.open_preop("preop_emi")
	emi_prep.procedure_id = "surgery_open_abdominal_myomectomy"
	emi_prep.flags.assign(["skin_disinfected", "awake_anesthesia", "epidural_anesthesia"])
	emi_prep.stage_id = "skin_disinfection_response"
	app.show_preop("preop_emi")
	expect(app.page.get_node_or_null("PreopAction_ack_disinfection") != null, "Normal draping button rendered")
	expect(not app.page.get_node("PreopAction_ack_disinfection").has_meta("mischief_hint"), "Normal draping button is not marked mischief")
	var skip_btn: Button = app.page.get_node_or_null("PreopAction_skip_sterile_draping")
	expect(skip_btn != null, "Skip draping button rendered")
	if skip_btn != null:
		expect(bool(skip_btn.get_meta("mischief_hint", false)) and skip_btn.text.begins_with("😈 "), "Skip draping button shows 😈 mischief cue")
	app.preop_event({"kind": "action", "id": "skip_sterile_draping"})
	await process_frame
	expect(app.screen == "preop" and app.page.get_node_or_null("WardPreparationCG") == null, "Skip draping bypassed sterile_draping CG")
	expect(emi_prep.stage_id == "sterile_draping_skipped_response", "UI reached sterile_draping_skipped_response")
	app.preop_event({"kind": "action", "id": "ack_skip_sterile_draping"})
	await process_frame
	expect(emi_prep.stage_id == "incision_marking" and app.screen == "preop", "UI reached incision_marking after skipping draping")
	expect(app.ward_preparation_cg_pool_for("manual_urinary_catheterization", "patient_rie").get("id", "") == "urinary_catheterization_patient_rie", "Manual catheterization reuses patient urinary_catheterization CG pool")
	expect(app.ward_preparation_cg_pool_for("excessive_disinfection_breasts", "patient_rie").get("id", "") == "skin_disinfection_patient_rie", "Excessive disinfection reuses patient skin_disinfection CG pool")

	# 4. Step 0 mischief badge check across all 5 tagged options in zh_CN and en (including 3-col sweep layout).
	for ui_locale in ["zh_CN", "en"]:
		expect(app.content.load_all(ui_locale), "Reload app locale " + ui_locale)
		app.configure_game_content()
		var breast_def: Dictionary = app.content.find_record("preops", "preop_sora").duplicate(true)
		breast_def["surgery_id"] = "surgery_breast_tumor"
		breast_def["_locale"] = ui_locale
		for sweep_unlocked in [false, true]:
			if sweep_unlocked:
				app.game.unlock_procedure("surgery_breast_tumor")
				app.game.completed_surgeries_by_procedure["surgery_breast_tumor"] = 1
			else:
				app.game.completed_surgeries_by_procedure.erase("surgery_breast_tumor")
			var m_prep = Preop.new(breast_def, app.content.collections.staff, app.content.collections.surgeries, app.content.collections.patients)
			m_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": "nurse_rin", "ward_nurse": "nurse_yui"}
			var stage_checks := [
				{"stage": "graphic_preop_question", "flags": ["announced"], "mischief": "graphic_answer", "normal": "appropriate_answer"},
				{"stage": "preparation", "flags": ["team_confirmed"], "mischief": "begin_manual_ward_preparation", "normal": "perform_preparation"},
				{"stage": "ward_enema", "flags": ["manual_ward_preparation"], "mischief": "ward_enema_unnecessary", "normal": "skip_ward_enema"},
				{"stage": "ward_skin_prep", "flags": ["ward_enema_complete"], "mischief": "ward_skin_prep_unnecessary", "normal": "skip_ward_skin_prep"},
				{"stage": "operative_positioning", "flags": ["anesthesia_chosen", "awake_anesthesia"], "mischief": "operative_positioning_unnecessary_lithotomy", "normal": "operative_positioning"},
				{"stage": "urinary_catheterization", "flags": ["operative_positioned", "awake_anesthesia"], "mischief": "begin_manual_catheterization", "normal": "urinary_catheterization"},
				{"stage": "manual_catheter_bladder_press", "flags": ["urinary_catheterized", "manual_catheter_inserted", "awake_anesthesia"], "mischief": "manual_catheter_press_bladder", "normal": "skip_bladder_press"},
				{"stage": "skin_disinfection", "flags": ["urinary_catheterized", "awake_anesthesia"], "mischief": "begin_excessive_disinfection", "normal": "skin_disinfection"},
				{"stage": "excessive_disinfection_perineum", "flags": ["skin_disinfected", "excessive_disinfection_upper_done", "awake_anesthesia"], "mischief": "excessive_disinfection_perineum", "normal": "stop_excessive_disinfection"},
				{"stage": "skin_disinfection_response", "flags": ["skin_disinfected", "awake_anesthesia"], "mischief": "skip_sterile_draping", "normal": "ack_disinfection"},
				{"stage": "incision_marking", "flags": ["skin_disinfected", "awake_anesthesia"], "mischief": "begin_slow_incision_marking", "normal": "incision_marking"},
				{"stage": "slow_incision_tracing", "flags": ["slow_incision_marking_started", "awake_anesthesia"], "mischief": "slow_incision_trace", "normal": "finish_incision_marking_normally"},
				{"stage": "incision_public_lecture", "flags": ["slow_incision_traced", "awake_anesthesia"], "mischief": "incision_public_lecture", "normal": "skip_incision_lecture"},
				{"stage": "procedure_execute", "flags": ["interaction_complete", "awake_anesthesia"], "mischief": "begin_postop_bare_inspection", "normal": "execute_confirmed_procedure"},
				{"stage": "postop_bare_wipe", "flags": ["postop_bare_cleanup_started", "awake_anesthesia"], "mischief": "postop_bare_sponge_wipe", "normal": "finish_postop_cover_sheet"},
				{"stage": "postop_bare_inspection", "flags": ["postop_bare_wiped", "awake_anesthesia"], "mischief": "postop_bare_full_inspection", "normal": "skip_postop_inspection"},
			]
			for check_row in stage_checks:
				m_prep.stage_id = str(check_row.stage)
				m_prep.flags.assign(check_row.flags)
				PreopView.render(app, m_prep)
				var m_btn: Button = app.page.get_node_or_null("PreopAction_" + str(check_row.mischief))
				var n_btn: Button = app.page.get_node_or_null("PreopAction_" + str(check_row.normal))
				expect(m_btn != null and bool(m_btn.get_meta("mischief_hint", false)) and m_btn.text.begins_with("😈 "), "Mischief cue rendered on " + str(check_row.mischief) + " (" + ui_locale + ")")
				expect(n_btn != null and not n_btn.has_meta("mischief_hint") and not n_btn.text.begins_with("😈"), "Normal option stays clean on " + str(check_row.normal) + " (" + ui_locale + ")")
				if m_btn != null:
					var font := m_btn.get_theme_font("font")
					var fsize := m_btn.get_theme_font_size("font_size")
					var measured := font.get_multiline_string_size(m_btn.text, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize)
					var usable := m_btn.size - m_btn.get_theme_stylebox("normal").get_minimum_size()
					expect(measured.x <= usable.x + 1 and measured.y <= usable.y + 1, "Mischief button fits bounds: " + m_btn.name + " (" + ui_locale + ", sweep=" + str(sweep_unlocked) + ")")
					if ui_locale == "en":
						expect(han.search(m_btn.text + m_btn.tooltip_text) == null, "No CJK in English mischief button/tooltip: " + m_btn.name)
			m_prep.procedure_id = "surgery_breast_tumor"
			m_prep.procedure_state = {"progress": 100, "stability": 90}
			m_prep.operative_background_id = "or_team_01"
			m_prep.stage_id = "procedure_execute"
			m_prep.flags.assign(["incision_made", "interaction_complete", "awake_anesthesia"])
			expect(m_prep.apply({"kind": "action", "id": "begin_postop_bare_inspection"}), "UI postop start (" + ui_locale + ")")
			PreopView.render(app, m_prep)
			expect(app.page.get_node_or_null("IntraoperativePatientPortrait") != null, "Postop bare wipe renders IntraoperativePatientPortrait near_collapse (" + ui_locale + ")")
			expect(m_prep.apply({"kind": "action", "id": "postop_bare_sponge_wipe"}) and m_prep.apply({"kind": "action", "id": "postop_bare_full_inspection"}) and m_prep.apply({"kind": "action", "id": "ack_postop_nurse_commentary"}), "UI postop nurse commentary (" + ui_locale + ")")
			PreopView.render(app, m_prep)
			expect(app.page.get_node_or_null("StaffInteractionPortrait") != null, "Postop nurse cover remark renders StaffInteractionPortrait on procedure_execute (" + ui_locale + ")")

	# 5. Staff-as-Patient dedicated OR mischief reactions & colleague team_overrides (doc_sayaka, doc_serika, nurse_yui) in zh_CN and en.
	var StaffRegistry = preload("res://godot/systems/staff_patient_registry.gd")
	var staff_mischief_keys := [
		"operative_positioning_unnecessary_lithotomy",
		"manual_catheter_press_bladder",
		"excessive_disinfection_breasts",
		"excessive_disinfection_perineum",
		"skip_sterile_draping",
		"slow_incision_trace",
		"incision_public_lecture",
		"postop_bare_sponge_wipe",
		"postop_bare_full_inspection",
	]
	for sp_locale in ["zh_CN", "en"]:
		expect(app.content.load_all(sp_locale), "Reload content for staff-patient mischief (" + sp_locale + ")")
		for actor_id in ["doc_sayaka", "doc_serika", "nurse_yui"]:
			var person: Dictionary = app.content.find_record("staff", actor_id)
			var surgery: Dictionary = app.content.find_record("surgeries", "surgery_breast_tumor")
			var sp_patient: Dictionary = StaffRegistry.patient_record(person, sp_locale)
			var sp_def: Dictionary = StaffRegistry.preop_definition(person, surgery, sp_locale)
			var sp_extra: Dictionary = StaffRegistry.mischief_dialogue(actor_id, sp_locale)
			expect(not sp_extra.is_empty(), "Mischief dialogue loaded for " + actor_id + " (" + sp_locale + ")")
			var circ_nurse := "nurse_rin"
			var ward_nurse := "nurse_ange" if actor_id == "nurse_yui" else "nurse_yui"
			var sp_prep = Preop.new(sp_def, app.content.collections.staff, app.content.collections.surgeries, [sp_patient], [], false, [], app.content.collections.patient_interactions)
			sp_prep.team = {"assistant_surgeon": "doc_aoi", "scrub_nurse": "nurse_haru", "circulating_nurse": circ_nurse, "ward_nurse": ward_nurse}
			sp_prep.procedure_id = "surgery_breast_tumor"
			sp_prep.procedure_name = str(surgery.name)
			sp_prep.procedure_state = {"progress": 100, "stability": 92}
			for rkey in staff_mischief_keys:
				var expected_variants: Array = sp_extra.get("reaction_variants", {}).get(rkey, [])
				expect(expected_variants.size() == 2, actor_id + " has 2 authored mischief variants for " + rkey + " (" + sp_locale + ")")
				var seen_sp := {}
				for idx in range(60):
					sp_prep.event_count = idx
					var rline: String = sp_prep.patient_reaction(rkey, "BAD_FALLBACK")
					expect(expected_variants.has(rline), actor_id + " resolves dedicated mischief variant for " + rkey + " (" + sp_locale + ")")
					if sp_locale == "en":
						expect(han.search(rline) == null, actor_id + " English mischief variant has zero CJK for " + rkey)
					seen_sp[rline] = true
				expect(seen_sp.size() == 2, actor_id + " reaches both mischief variants for " + rkey + " (" + sp_locale + ")")
			# Full OR chain execution on the staff patient, including colleague circulating-nurse team_overrides.
			sp_prep.stage_id = "operative_positioning"
			sp_prep.flags.assign(["announced", "explained", "procedure_selected", "team_confirmed", "prepared", "entered_or", "anesthesia_chosen", "awake_anesthesia"])
			var sp_chain := [
				{"action": "operative_positioning_unnecessary_lithotomy", "speaker": "patient", "rkey": "operative_positioning_unnecessary_lithotomy"},
				{"action": "ack_positioning", "speaker": "narrator", "rkey": ""},
				{"action": "begin_manual_catheterization", "speaker": "staff", "rkey": ""},
				{"action": "manual_urinary_catheterization", "speaker": "patient", "rkey": ""},
				{"action": "manual_catheter_press_bladder", "speaker": "patient", "rkey": "manual_catheter_press_bladder"},
				{"action": "nurse_verify_catheter_drainage", "speaker": "staff", "team_key": "nurse_verify_catheter_drainage", "nurse": circ_nurse},
				{"action": "ack_catheterization", "speaker": "narrator", "rkey": ""},
				{"action": "begin_excessive_disinfection", "speaker": "staff", "rkey": ""},
				{"action": "excessive_disinfection_breasts", "speaker": "patient", "rkey": "excessive_disinfection_breasts"},
				{"action": "excessive_disinfection_perineum", "speaker": "patient", "rkey": "excessive_disinfection_perineum"},
				{"action": "ack_disinfection_drying", "speaker": "staff", "team_key": "ack_disinfection_drying", "nurse": "nurse_haru"},
				{"action": "skip_sterile_draping", "speaker": "patient", "rkey": "skip_sterile_draping"},
				{"action": "ack_skip_sterile_draping", "speaker": "narrator", "rkey": ""},
				{"action": "begin_slow_incision_marking", "speaker": "player", "rkey": ""},
				{"action": "slow_incision_trace", "speaker": "patient", "rkey": "slow_incision_trace"},
				{"action": "incision_public_lecture", "speaker": "patient", "rkey": "incision_public_lecture"},
				{"action": "ack_incision_nurse_commentary", "speaker": "staff", "team_key": "ack_incision_nurse_commentary", "nurse": circ_nurse},
			]
			for step in sp_chain:
				expect(sp_prep.apply({"kind": "action", "id": str(step.action)}), actor_id + " apply " + str(step.action) + " (" + sp_locale + "): " + sp_prep.last_error)
				expect(sp_prep.feedback_speaker == str(step.speaker), actor_id + " speaker on " + str(step.action) + " (" + sp_locale + ")")
				if not str(step.get("rkey", "")).is_empty():
					var rk := str(step.rkey)
					expect(sp_extra["reaction_variants"][rk].has(sp_prep.feedback), actor_id + " live feedback matches authored " + rk + " (" + sp_locale + ")")
				if step.has("team_key"):
					var tk := str(step.team_key)
					var tn := str(step.nurse)
					var expected_team_line := str(sp_prep.roster[tn].name) + "：" + str(sp_extra["team_overrides"][tn][tk])
					expect(sp_prep.feedback == expected_team_line, actor_id + " colleague nurse team_override fired for " + tk + " (" + sp_locale + ")")
			sp_prep.stage_id = "procedure_execute"
			sp_prep.flags.append_array(["incision_made", "interaction_complete"])
			expect(sp_prep.apply({"kind": "action", "id": "begin_postop_bare_inspection"}), actor_id + " postop start (" + sp_locale + ")")
			expect(sp_prep.apply({"kind": "action", "id": "postop_bare_sponge_wipe"}) and sp_extra["reaction_variants"]["postop_bare_sponge_wipe"].has(sp_prep.feedback), actor_id + " postop wipe line (" + sp_locale + ")")
			expect(sp_prep.apply({"kind": "action", "id": "postop_bare_full_inspection"}) and sp_extra["reaction_variants"]["postop_bare_full_inspection"].has(sp_prep.feedback), actor_id + " postop inspect line (" + sp_locale + ")")
			var expected_postop_team := str(sp_prep.roster[circ_nurse].name) + "：" + str(sp_extra["team_overrides"][circ_nurse]["ack_postop_nurse_commentary"])
			expect(sp_prep.apply({"kind": "action", "id": "ack_postop_nurse_commentary"}) and sp_prep.feedback == expected_postop_team, actor_id + " postop nurse colleague remark (" + sp_locale + ")")
			expect(sp_prep.apply({"kind": "action", "id": "execute_confirmed_procedure"}) and sp_prep.surgery_success, actor_id + " concludes surgery cleanly after full mischief chain (" + sp_locale + ")")

	app.queue_free()
	await process_frame

	print("SKIP STERILE DRAPING: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

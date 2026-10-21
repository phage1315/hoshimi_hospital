extends SceneTree
const Loader = preload("res://godot/scripts/content_loader.gd")
const Registry = preload("res://godot/systems/staff_patient_registry.gd")
const Preop = preload("res://godot/systems/preop_session.gd")
var content = Loader.new()
var checks := 0
var failures := 0

func expect(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func session(surgery_id: String, locale: String) -> RefCounted:
	var person: Dictionary = content.find_record("staff", "doc_sayaka")
	return Preop.new(Registry.preop_definition(person, content.find_record("surgeries", surgery_id), locale),
		content.collections.staff, content.collections.surgeries, [Registry.patient_record(person, locale)],
		[], false, [], content.collections.patient_interactions)

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	for locale in ["zh_CN", "en"]:
		expect(content.load_all(locale), locale + " load")
		var lines := Registry.dialogue("doc_sayaka", locale)
		expect(lines.invitation_by_procedure.size() == 32, "All invitations mapped")
		expect(lines.interaction_overrides.size() == 39, "39 active v1 pools")
		var prep = session("surgery_breast_tumor", locale)
		# Every v1 response uses existing action IDs and preserves all mechanics.
		for original in content.collections.patient_interactions:
			var original_copy: Dictionary = original.duplicate(true)
			var actual: Dictionary = prep.patient_interaction_with_overrides(original)
			if lines.interaction_overrides.has(original.id):
				var expected: Dictionary = lines.interaction_overrides[original.id]
				expect(actual.prompt == expected.prompt, locale + " prompt " + original.id)
				for a in actual.actions:
					expect(a.response == expected.responses[a.id], locale + " response " + a.id)
			else:
				expect(actual == original, "Fallback unchanged " + original.id)
			actual.prompt = original.prompt
			for i in range(actual.actions.size()):
				actual.actions[i].response = original.actions[i].response
			expect(actual == original_copy and original == original_copy, "Text-only independent clone " + original.id)
		for rid in lines.reaction_variants:
			var seen: Dictionary = {}
			for index in range(80):
				prep.event_count = index
				var response: String = prep.patient_reaction(rid, "BAD_FALLBACK")
				expect(lines.reaction_variants[rid].has(response), "Variant from source " + rid)
				seen[response] = true
			expect(seen.size() == 2, "Both authored variants reachable " + rid)
		# Full production selector, using the real mismatch action.
		prep.stage_id = "procedure_select"
		expect(prep.apply({"kind": "procedure", "id": "surgery_hysterectomy"}), "Select actual surgery")
		expect(prep.procedure_mismatch and prep.feedback == lines.reaction_lines.procedure_mismatch and prep.feedback_speaker == "patient", "Authored mismatch patient response")
		var forbidden: Array = prep.definition.agreement_required_interaction_ids
		var selected: Dictionary = prep.match_patient_interaction("dignity_interaction", ["deep_manipulation"], "default")
		expect(not selected.is_empty() and not forbidden.has(str(selected.id)), "Breast -> uterus uses eligible fallback")
		# All eleven filters, including fallback-only pools, at matching conditions.
		for pool in content.collections.patient_interactions:
			if not forbidden.has(pool.id):
				continue
			var actual_surgery := ""
			for surgery in content.collections.surgeries:
				if prep.patient_interaction_scope(pool, surgery.id, surgery.procedure_group) >= 0:
					actual_surgery = surgery.id
					break
			var fixture = session(actual_surgery, locale)
			fixture.procedure_id = actual_surgery
			fixture.patient_interactions = [pool]
			var state: String = str(pool.states[0]) if not pool.states.is_empty() else "default"
			expect(not fixture.match_patient_interaction(pool.theme, pool.cues, state).is_empty(), "Agreement permits " + pool.id)
			fixture.definition.agreed_procedure_id = "surgery_appendix" if actual_surgery != "surgery_appendix" else "surgery_breast_tumor"
			expect(fixture.match_patient_interaction(pool.theme, pool.cues, state).is_empty(), "Mismatch filters " + pool.id)
			fixture.definition.erase("staff_patient_id")
			expect(not fixture.match_patient_interaction(pool.theme, pool.cues, state).is_empty(), "Ordinary patient unchanged " + pool.id)
		# No-anesthesia pool ordering and asleep suppression.
		prep = session("surgery_appendix", locale)
		prep.procedure_id = "surgery_appendix"
		prep.flags.append("no_anesthesia_confirmed")
		for i in range(3):
			selected = prep.match_patient_interaction("operative_contact", ["incision"], "pain")
			expect(selected.get("id") == "contact_no_anesthesia_incision_0" + str(i + 1), "No-anesthesia pool order")
			prep.patient_interaction_history.append(str(selected.id))
		prep.flags.append("anesthetized")
		expect(not prep.resolve_patient_event_for_stage(), "No conscious dialogue under GA")
		# Breast's authored excision stage can reach the generic traction pool.
		prep = session("surgery_breast_tumor", locale)
		prep.procedure_id = "surgery_breast_tumor"
		var cues: Array = []
		for step in prep.current_surgery().stages:
			if step.id == "breast_04_excision":
				cues = step.patient_cues
		var traction_label := ""
		for i in range(6):
			selected = prep.match_patient_interaction("strain_interaction", cues, "pain")
			prep.patient_interaction_history.append(str(selected.id))
			for a in selected.actions:
				if a.id == "coach_second_traction":
					traction_label = a.label
		expect(not traction_label.is_empty() and not traction_label.contains("腹部") and not traction_label.to_lower().contains("abdom"), "Neutral breast traction label")
		# The real ward action opens the five-node explanation; no new stage.
		prep = session("surgery_vaginal_hysterectomy", locale)
		expect(prep.apply({"kind": "action", "id": "explain_plan"}), "Explain action")
		expect(prep.feedback_speaker == "patient" and prep.feedback.begins_with(lines.reaction_lines.explain_plan), "Explain speaker is patient")
		expect(prep.feedback.ends_with(prep.patient_dialogue_text(lines.stage_prompts.graphic_preop_question)), "Question not hidden by action feedback")
		expect(prep.apply({"kind": "action", "id": "graphic_answer"}), "Open detailed explanation")
		var authored: Dictionary = lines.graphic_preop_by_procedure.surgery_vaginal_hysterectomy
		var original_nodes: Array = prep.definition.graphic_preop.families.gynecology_pelvic.nodes
		expect(prep.graphic_preop_nodes.size() == original_nodes.size(), "No added/removed explanation nodes")
		var seen_nodes: Array[String] = []
		while prep.stage_id == "graphic_preop_dialogue":
			var node: Dictionary = prep.graphic_preop_nodes[prep.graphic_preop_node_index]
			if authored.has(node.id):
				seen_nodes.append(node.id)
				expect(node.text == authored[node.id].text and node.speaker == authored[node.id].speaker, "Exact scoped node " + node.id)
				expect(prep.feedback == node.text and prep.feedback_speaker == ("patient" if node.speaker == "patient" else "staff"), "Rendered speaker " + node.id)
			elif node.speaker != "explainer" or original_nodes[prep.graphic_preop_node_index].speaker != "wrapper":
				expect(node == original_nodes[prep.graphic_preop_node_index], "Other middle nodes preserved " + node.id)
			if node.id == "bladder":
				var saved: Dictionary = JSON.parse_string(JSON.stringify(prep.snapshot_state()))
				saved.patient_reactions = {}
				var restored = session("surgery_vaginal_hysterectomy", locale)
				expect(restored.restore_state(saved), "Save restores")
				expect(restored.feedback_speaker == "patient" and restored.feedback == node.text, "Approved speaker survives reload")
				expect(restored.patient_reactions.explain_plan == lines.reaction_lines.explain_plan, "Old save refreshes approved lines")
			expect(prep.apply({"kind": "graphic_preop_next"}), "Advance existing explanation")
		expect(seen_nodes == ["field", "bowel", "bowel_answer", "bladder", "manipulator"], "Five node order")
		expect(prep.stage_id == "team" and prep.procedure_id.is_empty() and prep.anesthesia == "未选择", "Ward does not select surgery/anesthesia")
		prep = session("surgery_hysterectomy", locale)
		expect(prep.initialize_graphic_preop_dialogue(), "Open abdominal control")
		for node in prep.graphic_preop_nodes:
			if node.id == "bladder":
				expect(node.speaker == "explainer" and node.text != authored.bladder.text, "Abdominal control not overwritten")
	print("SAYAKA V1.6 DIALOGUE: %s checks; %s failure(s)" % [checks, failures])
	quit(1 if failures else 0)

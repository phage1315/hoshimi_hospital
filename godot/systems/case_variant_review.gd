extends RefCounted
## Build an in-memory preoperative review from the unchanged case-template prose.
## Nothing here is a save contract or a follow-up story implementation.

static func enabled_variants(definition: Dictionary) -> Array:
	return definition.get("case_rare_variants", []).filter(func(item: Dictionary): return bool(item.get("runtime_enabled", false)))

static func entry_id(variant: Dictionary) -> String:
	return "case_review_" + str(variant.id)

static func action(id: String, label: String, next: String) -> Dictionary:
	return {"id": id, "label": label, "next": next, "response": "", "response_speaker": "narrator",
		"requires": [], "flags": [], "calm": 0, "minutes": 0, "requires_team": false, "execute_preparation": false}

static func stage(id: String, title: String, prompt: String, speaker: String, actions: Array) -> Dictionary:
	return {"id": id, "title": title, "prompt": prompt, "speaker": speaker, "actions": actions,
		"scene": "ward", "background_id": "ward", "kind": "case_review"}

static func stages_for(definition: Dictionary) -> Array:
	var result := []
	var english := str(definition.get("_locale", "zh_CN")) == "en"
	var title := "Preoperative Case Review" if english else "术前病例复核"
	var next_label := "Continue →" if english else "继续 →"
	for variant in enabled_variants(definition):
		var root := entry_id(variant)
		# Keep the quote and its following narration verbatim, on separate turns.
		var objection := str(variant.exploratory_surgery_reaction)
		var quote_end := objection.find("”" if english else "」") + 1
		var spoken := objection.left(quote_end)
		var narration := objection.substr(quote_end).strip_edges()
		result.append(stage(root, title, str(variant.reveal_text), "narrator", [action(root + "_next", next_label, root + "_objection")]))
		result.append(stage(root + "_objection", title, spoken, "patient", [action(root + "_listen", next_label, root + "_decision")]))
		var choices := []
		for option in variant.decision_options:
			if str(option.id) not in variant.get("runtime_options", []):
				continue
			var branch := root + "_" + str(option.id)
			var choice := action(branch, str(option.label), branch + "_answer")
			choice.response = str(option.dialogue)
			choice.response_speaker = "player"
			choice.presence_delta = int(option.effects.get("presence", 0))
			choice.effects = {"fear": int(option.effects.get("fear", 0)), "dignity": int(option.effects.get("dignity", 0))}
			# Trust is retired. Future intervention hooks remain definitions only.
			choice.flags = option.get("event_flags", []).duplicate()
			choices.append(choice)
			result.append(stage(branch + "_answer", title, str(option.dialogue), "player", [action(branch + "_next", next_label, branch + "_outcome")]))
			result.append(stage(branch + "_outcome", title, str(option.outcome), "narrator", [action(branch + "_resume", next_label, str(definition.start))]))
		result.append(stage(root + "_decision", title, narration, "narrator", choices))
	return result

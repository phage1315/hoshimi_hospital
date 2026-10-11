extends RefCounted
## Presentation-only formatting. Save records retain their original labels;
## stable IDs and numeric XP are resolved in the current display language.

const TIERS := {
	"平常": "charm_0", "得体": "charm_1", "出众": "charm_2", "迷人": "charm_3", "非凡": "charm_4", # localization-invariant: game-state tier identifiers
	"可亲型": "presence_0", "温和型": "presence_1", "平衡型": "presence_2", "强势型": "presence_3", "威压型": "presence_4", # localization-invariant: game-state tier identifiers
}

static func tier(app, source: String) -> String:
	return app.tx("ui.profile.tier." + str(TIERS.get(source, "unknown")), source)

static func history_label(app, record: Dictionary) -> String:
	var id := str(record.get("id", ""))
	var source := str(record.get("label", ""))
	if id == "character_choice_charm":
		return app.tx("ui.profile.history.character_charm", "角色事件选择 · 魅力")
	if id == "character_choice_presence":
		return app.tx("ui.profile.history.character_presence", "角色事件选择 · 临床气场")
	if id.begins_with("sunday_date_"):
		return app.tx("ui.profile.history.sunday_date", "星期日约会 · 魅力 +1")
	var surgery_id := str(record.get("surgery_id", ""))
	for prefix in ["surgery_reputation_", "surgery_penalty_"]:
		if id.begins_with(prefix) and surgery_id.is_empty():
			var identity := id.trim_prefix(prefix)
			surgery_id = identity.left(identity.rfind("_"))
	var title := str(app.game.surgery_definition(surgery_id).get("name", source))
	if id.begins_with("surgery_reputation_"):
		var profile: Dictionary = app.game.surgery_reputation_profile(surgery_id)
		var difficulty: String = app.tx("ui.profile.difficulty." + str(profile.get("tier", "standard")), str(profile.get("label", "")))
		return app.tx("ui.profile.history.reputation", "%s · %s术式声望 +%s") % [title, difficulty, str(record.get("effects", {}).get("reputation", 0))]
	if id.begins_with("surgery_penalty_"):
		return app.tx("ui.profile.history.surgery_penalty", "%s · 手术处置影响 %s") % [title, str(record.get("effects", {}).get("reputation", 0))]
	if id.begins_with("special_event_"):
		var event_id := id.trim_prefix("special_event_").trim_suffix("_reputation")
		title = str(app.game.special_event_definitions.get(event_id, {}).get("title", title))
		if not record.has("xp"):
			return title
	if record.has("xp"):
		if id.begins_with("leadership_"):
			return app.tx("ui.profile.history.leadership_xp", "%s · 领导经验 +%s") % [title, "%.1f" % float(record.xp)]
		return app.tx("ui.profile.history.surgery_xp", "%s · 手术经验 +%s") % [title, str(int(record.xp))]
	for definition in app.game.time_event_definitions.values():
		if id == str(definition.id) or id.begins_with(str(definition.id) + "_"):
			return str(definition.label)
	# Choice IDs are shared by the patient templates. Use current-language
	# authored labels, never replace pieces of saved narrative text blindly.
	for collection in ["encounters", "preops", "patient_interactions"]:
		for definition in app.content.collections.get(collection, []):
			var found := choice_label(definition, id)
			if not found.is_empty():
				return found
	return source

static func choice_label(value: Variant, id: String) -> String:
	if value is Dictionary:
		if str(value.get("id", "")) == id and value.has("label"):
			return str(value.label)
		for child in value.values():
			var found := choice_label(child, id)
			if not found.is_empty():
				return found
	elif value is Array:
		for child in value:
			var found := choice_label(child, id)
			if not found.is_empty():
				return found
	return ""

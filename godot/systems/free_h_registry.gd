extends RefCounted
## Explicit production opt-in. A relationship level or a dialogue location pool
## alone never registers a route. Each entry owns exactly one repeatable location.
const Content = preload("res://godot/systems/h_profile_v1_content.gd")
const Session = preload("res://godot/systems/h_profile_v1_session.gd")
const ACTORS := {
	"doc_sayaka": {
		"location_id": "hotel",
		"completion_event": "sayaka_lv4_hotel_date",
		"completion_flag": "sayaka_lv4_complete",
		"adapter": "sayaka_v1",
		"profile": "res://data/staff/doc_sayaka/h_profile_v1_3_2.json",
		"flow": "res://data/staff/doc_sayaka/h_flow_v1_3_2.json",
		"finish_labels": "res://data/h_finish_button_labels_v1_3_4.json",
		"finish_actor": "res://data/staff/doc_sayaka/h_phase2_finish_v1_3_4.json",
		"bodymap": "res://data/staff/doc_sayaka/h_bodymap_v1.draft.json",
		"context": "res://data/staff/doc_sayaka/h_context_overrides_v1.json",
	},
	"doc_serika": {
		"content_status": "ready",
		"location_id": "home",
		"fixed_location": true,
		"location_label_key": "ui.free_h.location.doc_serika_home",
		"location_label": "芹香家",
		"booking_response_key": "ui.free_h.doc_serika.booking_response",
		"booking_response": "那今晚去我家吧。",
		"completion_kind": "special_event",
		"completion_event": "serika_lv4_stay",
		"completion_flag": "",
		"adapter": "authored_v1_3",
		"profile": "res://data/staff/doc_serika/h_profile_v1_1.json",
		"flow": "res://data/staff/doc_serika/h_flow_v1_1.json",
		"finish_labels": "res://data/h_finish_button_labels_v1_3_4.json",
		"finish_actor": "",
		"bodymap": "res://data/h/doc_serika/h_bodymap.json",
		"context": "res://data/staff/doc_serika/h_context_v1_1.json",
	},
	"nurse_yui": {
		"content_status": "pending_assets",
		"location_id": "clinic",
		"fixed_location": true,
		"location_label_key": "ui.free_h.location.nurse_yui_clinic",
		"location_label": "私人诊所",
		"completion_event": "miyuki_lv4_inspection",
		"completion_flag": "",
		"adapter": "authored_v1_3",
		"profile": "res://data/staff/nurse_yui/h_profile_v1.json",
		"flow": "res://data/staff/nurse_yui/h_flow_v1.json",
		"finish_labels": "res://data/h_finish_button_labels_v1_3_4.json",
		"finish_actor": "",
		"bodymap": "res://data/h/nurse_yui/h_bodymap.json",
		"context": "res://data/staff/nurse_yui/h_context_v1.json",
	},
}

static func definition(actor_id: String) -> Dictionary:
	return ACTORS.get(actor_id, {}).duplicate(true)

static func read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var value: Variant = JSON.parse_string(file.get_as_text())
	return value if value is Dictionary else {}

static func load_bundle(actor_id: String, locale: String = "zh_CN") -> Dictionary:
	var config := definition(actor_id)
	if config.is_empty():
		return {"error": "Unregistered actor: " + actor_id}
	if str(config.get("content_status", "ready")) != "ready":
		return {"error": "Character assets are not complete: " + actor_id}
	var sources: Dictionary = {}
	for key in ["profile", "flow", "finish_labels", "finish_actor", "bodymap", "context"]:
		if key == "finish_actor" and str(config.get(key, "")).is_empty():
			sources[key] = {}
			continue
		sources[key] = read_json(str(config[key]))
		if sources[key].is_empty():
			return {"error": "Missing or invalid resource: " + str(config[key])}
	if str(config.adapter) not in ["sayaka_v1", "authored_v1_3"] or str(sources.profile.get("actor_id", "")) != actor_id or not bool(sources.profile.get("adult_confirmed", false)):
		return {"error": "Unsupported profile adapter or actor: " + actor_id}
	var profile := Content.normalize(sources.profile, sources.flow, sources.finish_labels, sources.finish_actor, sources.context)
	if profile.is_empty():
		return {"error": "Profile validation failed: " + actor_id}
	return validate_bundle(actor_id, str(config.location_id), profile, sources.bodymap, locale)

static func validate_bundle(actor_id: String, location_id: String, source_profile: Dictionary, bodymap: Dictionary, locale: String) -> Dictionary:
	var profile := source_profile.duplicate(true)
	if not profile.get("context_overrides") is Dictionary or not bodymap.get("hotspots") is Dictionary:
		return {"error": "Invalid context or hit map: " + actor_id}
	var layout: Dictionary = profile.get("body_map_layout", {})
	if int(bodymap.get("image_width", 0)) != int(layout.get("width", -1)) or int(bodymap.get("image_height", 0)) != int(layout.get("height", -1)):
		return {"error": "Hit map dimensions do not match the registered layout: " + actor_id}
	for zone in Session.ZONES:
		if not bodymap.hotspots.get(zone) is Array or bodymap.hotspots[zone].is_empty():
			return {"error": "Missing hit map region: " + zone}
	# No event identifier, no event overlays, no milestone completion callback.
	profile.context_overrides["events"] = {}
	var session := Session.new(actor_id, profile, location_id, "", locale)
	if session.phase == "invalid":
		return {"error": "Session validation failed: " + actor_id}
	var entry: Array = session.location_entry_lines(profile.get("location_entry", {}).get(location_id, []))
	var aftercare: Array = session.aftercare_lines(profile.flow.get("free_aftercare_lines", []))
	if entry.is_empty() or aftercare.is_empty():
		return {"error": "Missing entry or ordinary completion text: " + actor_id}
	var images := [session.body_map_image(), session.h_stage_image(), session.after_cg_image()]
	var atlas := str(profile.get("expression_atlas", ""))
	if atlas.is_empty():
		for expression in Session.EXPRESSION_IDS:
			images.append(str(profile.get("expressions", {}).get(expression, "")))
	else:
		images.append(atlas)
	var background_id: String = session.background_id("")
	var background_file := FileAccess.open("res://data/backgrounds.json", FileAccess.READ)
	var backgrounds: Variant = JSON.parse_string(background_file.get_as_text()) if background_file != null else null
	var background_path := ""
	if backgrounds is Array:
		for background in backgrounds:
			if str(background.get("id", "")) == background_id:
				background_path = "res://" + str(background.get("path", ""))
	images.append(background_path)
	for path in images:
		if str(path).is_empty() or not ResourceLoader.exists(str(path)):
			return {"error": "Missing image: " + str(path)}
	if not session.last_error.is_empty():
		return {"error": session.last_error}
	return {"profile": profile, "bodymap": bodymap, "location_id": location_id, "session": session}

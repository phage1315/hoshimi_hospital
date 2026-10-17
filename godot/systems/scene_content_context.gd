extends RefCounted
## Neutral scene-content resolver. Pools are atomic; authored lines are never edited.
## No session progression, actor preferences, resource loading or event triggering.

var _bundle: Dictionary
var _location_id: String
var _event_id: String
var _locale: String
var _validation_error := ""

func _init(bundle: Dictionary, location_id: String = "", event_id: String = "", locale: String = "zh_CN") -> void:
	_bundle = bundle.duplicate(true)
	_location_id = location_id
	_event_id = event_id
	_locale = locale
	if not _bundle.get("base", {}) is Dictionary:
		_validation_error = "base must be a dictionary"
	for group in ["locations", "events"]:
		var entries: Variant = _bundle.get(group, {})
		if not entries is Dictionary:
			_validation_error = group + " must be a dictionary"
			continue
		for entry in entries.values():
			if not entry is Dictionary:
				_validation_error = group + " entries must be dictionaries"

## Try all candidate keys within each layer before moving to the next layer.
## This lets a contextual general pool override a base-specific pool deliberately.
func dialogue(candidate_keys: Array) -> Dictionary:
	if not _validation_error.is_empty():
		return _error(_validation_error, "bundle")
	for layer in _layers(true):
		var dialogue_map: Variant = layer.data.get("dialogue", {})
		if not dialogue_map is Dictionary:
			return _error("dialogue must be a dictionary", layer.source)
		var localized: Variant = dialogue_map.get(_locale, {})
		if not localized is Dictionary:
			return _error("locale entry must be a dictionary", layer.source)
		for key in candidate_keys:
			if not localized.has(key):
				continue
			var pool: Variant = localized[key]
			if not pool is Array or pool.is_empty():
				return _error("present dialogue pool must be a nonempty array", layer.source)
			return {"ok": true, "found": true, "value": pool.duplicate(true), "source": layer.source, "key": key}
	return {"ok": true, "found": false}

## Event overrides intentionally do not select assets. Each location slot falls
## back independently. A malformed present value is an error, not silent fallback.
func asset(slot: String, shared_layout: Dictionary = {}) -> Dictionary:
	if not _validation_error.is_empty():
		return _error(_validation_error, "bundle")
	for layer in _layers(false):
		var assets: Variant = layer.data.get("assets", {})
		if not assets is Dictionary:
			return _error("assets must be a dictionary", layer.source)
		if not assets.has(slot):
			continue
		var spec: Variant = assets[slot]
		if not spec is Dictionary:
			return _error("asset must be a dictionary", layer.source)
		var has_path := spec.get("path", null) is String and not str(spec.get("path", "")).is_empty()
		var has_id := spec.get("id", null) is String and not str(spec.get("id", "")).is_empty()
		if not has_path and not has_id:
			return _error("asset requires a nonempty path or id", layer.source)
		if not shared_layout.is_empty():
			for field in ["layout_id", "width", "height"]:
				if not shared_layout.has(field) or not spec.has(field) or spec[field] != shared_layout[field]:
					return _error("shared layout mismatch: " + field, layer.source)
			if str(shared_layout.layout_id).is_empty() or float(shared_layout.width) <= 0 or float(shared_layout.height) <= 0:
				return _error("shared layout must have an ID and positive dimensions", layer.source)
		return {"ok": true, "found": true, "value": spec.duplicate(true), "source": layer.source}
	return {"ok": true, "found": false}

func _layers(include_event: bool) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if include_event and not _event_id.is_empty():
		result.append({"source": "event:" + _event_id, "data": _bundle.get("events", {}).get(_event_id, {})})
	if not _location_id.is_empty():
		result.append({"source": "location:" + _location_id, "data": _bundle.get("locations", {}).get(_location_id, {})})
	result.append({"source": "base", "data": _bundle.get("base", {})})
	return result

static func _error(message: String, source: String) -> Dictionary:
	return {"ok": false, "found": false, "error": message, "source": source}

## KEEP_ASPECT_CENTERED: exclude letterboxing before mapping pointer coordinates.
static func image_rect(container: Rect2, image_size: Vector2) -> Rect2:
	if image_size.x <= 0 or image_size.y <= 0 or container.size.x <= 0 or container.size.y <= 0:
		return Rect2()
	var scale_factor := minf(container.size.x / image_size.x, container.size.y / image_size.y)
	var displayed_size := image_size * scale_factor
	return Rect2(container.position + (container.size - displayed_size) * 0.5, displayed_size)

static func point_to_uv(point: Vector2, displayed_rect: Rect2) -> Vector2:
	if displayed_rect.size.x <= 0 or displayed_rect.size.y <= 0 or not displayed_rect.has_point(point):
		return Vector2(-1, -1)
	return (point - displayed_rect.position) / displayed_rect.size

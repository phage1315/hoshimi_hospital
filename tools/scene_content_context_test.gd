extends SceneTree

const Context = preload("res://godot/systems/scene_content_context.gd")
var checks := 0
var failures := 0

func expect(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(label)

func _init() -> void:
	var layout := {"layout_id": "portrait_front_v1", "width": 800, "height": 1200}
	var portrait := {"path": "res://example.png", "layout_id": "portrait_front_v1", "width": 800, "height": 1200}
	var bundle := {
		"base": {"dialogue": {"en": {"greeting": ["Welcome."], "specific": ["Base-specific."], "closing": ["Goodbye."]}, "zh_CN": {"greeting": ["你好。"]}}, "assets": {"portrait": portrait, "background": {"path": "res://base.png"}}},
		"locations": {"clinic": {"dialogue": {"en": {"greeting": ["Welcome to the clinic."]}}, "assets": {"background": {"path": "res://clinic.png"}}}},
		"events": {"introduction": {"dialogue": {"en": {"greeting": ["Nice to meet you."]}}}},
	}
	var context = Context.new(bundle, "clinic", "introduction", "en")
	expect(context.dialogue(["greeting"]).value == ["Nice to meet you."], "Event priority")
	expect(context.dialogue(["specific", "greeting"]).source == "event:introduction", "Layer priority before specificity")
	expect(context.dialogue(["closing"]).value == ["Goodbye."], "Sparse base fallback")
	expect(not context.dialogue(["absent"]).found, "Missing content remains explicit")
	expect(context.asset("background").value.path == "res://clinic.png", "Location image selected")
	expect(context.asset("portrait", layout).source == "base", "Independent image fallback and layout validation")
	expect(not context.asset("portrait", {"layout_id": "different", "width": 800, "height": 1200}).ok, "Reject incompatible layout")
	expect(not context.asset("absent").found, "Missing asset explicit")
	var location_context = Context.new(bundle, "clinic", "", "en")
	expect(location_context.dialogue(["greeting"]).source == "location:clinic", "No event leaks into next session")
	expect(Context.new(bundle, "unknown", "unknown", "en").dialogue(["greeting"]).source == "base", "Absent override falls back")
	expect(not Context.new(bundle, "clinic", "introduction", "fr").dialogue(["greeting"]).found, "No silent cross-language fallback")
	var returned: Dictionary = context.dialogue(["greeting"])
	returned.value[0] = "Changed"
	expect(context.dialogue(["greeting"]).value == ["Nice to meet you."], "Caller mutation cannot change resolver")
	bundle.events.introduction.dialogue.en.greeting[0] = "Changed source"
	expect(context.dialogue(["greeting"]).value == ["Nice to meet you."], "Source mutation cannot change active context")
	bundle.events.introduction.dialogue.en.greeting = []
	expect(not Context.new(bundle, "clinic", "introduction", "en").dialogue(["greeting"]).ok, "Empty override is an error, not silent fallback")
	expect(not Context.new({"locations": null}).asset("background").ok, "Malformed bundle returns error")
	var rect := Context.image_rect(Rect2(20, 30, 400, 400), Vector2(800, 1200))
	expect(Context.point_to_uv(rect.get_center(), rect).is_equal_approx(Vector2(0.5, 0.5)), "Centered UV with letterboxing")
	expect(Context.point_to_uv(Vector2(21, 31), rect) == Vector2(-1, -1), "Ignore pointer in letterbox")
	expect(Context.image_rect(Rect2(0, 0, 400, 400), Vector2.ZERO) == Rect2(), "Invalid image geometry safe")
	print("Scene content context: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)

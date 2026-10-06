extends SceneTree

var failures := 0
var checks := 0

func expect(condition: bool, message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func load_json(path: String) -> Variant:
	var parser := JSON.new()
	var error := parser.parse(FileAccess.get_file_as_string(path))
	expect(error == OK, "Could not parse %s" % path)
	return parser.data

func load_records(path: String) -> Array:
	var source: Variant = load_json(path)
	if source is Array:
		return source
	var rows: Array = []
	var base_dir := path.get_base_dir()
	for relative_path in source.get("files", []):
		var part: Variant = load_json(base_dir.path_join(str(relative_path)))
		if part is Array:
			rows.append_array(part)
	return rows

func audit_node(app: Control, source: String, node: Dictionary) -> void:
	if not node.has("text"):
		return
	var allow_scroll := bool(node.get("allow_dialogue_scroll", false))
	var pages: Array[String] = app.dialogue_pages(str(node.text), allow_scroll)
	expect(not pages.is_empty(), "%s produced no dialogue pages" % source)
	if allow_scroll:
		expect(pages.size() == 1, "%s scroll exception was unexpectedly paginated" % source)
		return
	for page_index in range(pages.size()):
		var page_text := pages[page_index]
		expect(not page_text.contains("\n"), "%s page %s still contains stacked lines" % [source, page_index + 1])
		expect(app.dialogue_estimated_lines(page_text) <= app.DIALOGUE_PAGE_LINES, "%s page %s exceeds the dialogue box estimate" % [source, page_index + 1])

func audit_authored_dialogue(app: Control) -> void:
	var introduction: Dictionary = load_json("res://data/dialogue/introduction.json")
	for node in introduction.get("nodes", []):
		audit_node(app, "introduction/%s" % str(node.get("id", "?")), node)
	for collection_spec in [
		["character_events", false],
		["special_event_steps", true],
	]:
		var records: Array = app.content.collections.get(str(collection_spec[0]), [])
		for record in records:
			for node in record.get("nodes", []):
				if bool(collection_spec[1]) and str(node.get("presentation", "narrative")) != "narrative":
					continue
				audit_node(app, "%s/%s/%s" % [str(collection_spec[0]), str(record.get("id", "?")), str(node.get("id", "?"))], node)
	var micro_events: Array = app.content.collections.get("micro_events", [])
	for event in micro_events:
		for section in ["opening_lines", "closing_lines"]:
			for index in range(event.get(section, []).size()):
				audit_node(app, "micro_events/%s/%s/%s" % [str(event.get("id", "?")), section, index], event[section][index])

func _initialize() -> void:
	call_deferred("run")

func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame

	var shiori_fixture := "「外科医生先看病灶很正常。内科会诊的意义，就是把镜头往后拉一点。」\n詩織没有卖弄结论，只把症状、用药和既往检查按时间重新排好。\n「漂亮的单项数据让人安心，但患者不是一张数据表。以后有术前风险拿不准的病例，请直接找我。」"
	var pages: Array[String] = app.dialogue_pages(shiori_fixture)
	expect(pages.size() == 3, "Shiori fixture was not split into three click points")
	var mixed_beat_pages: Array[String] = app.dialogue_pages("她脱口而出：「小夜香。」")
	expect(mixed_beat_pages == ["她脱口而出：", "「小夜香。」"], "Narration and actor speech were not separated")
	var player_pages: Array[String] = app.dialogue_pages("坂口接过：\n\n「谢了。」")
	expect(player_pages == ["坂口接过：「谢了。」"], "Player lead-in was detached from the player's line")
	var player_presentation: Dictionary = app.dialogue_page_presentation("南条小夜香", "actor", player_pages[0], "南条小夜香")
	expect(str(player_presentation.speaker) == app.protagonist_name() and str(player_presentation.text) == "「谢了。」", "Embedded player dialogue kept the wrong speaker label")
	for index in range(pages.size()):
		app.vn_dialogue_box("藤崎詩織", pages[index], "AuditDialogue_%s" % index)
		await process_frame
		var prose: RichTextLabel = app.page.get_node_or_null("AuditDialogue_%s" % index)
		expect(prose != null, "Audit dialogue control was not created")
		if prose != null:
			expect(not prose.scroll_active, "Ordinary VN dialogue still enables manual scrolling")
			expect(prose.get_content_height() <= prose.size.y, "Rendered dialogue page exceeds its frame")

	var long_text := "这是一段用于验证自动分页的长文本。".repeat(80)
	var long_pages: Array[String] = app.dialogue_pages(long_text)
	expect(long_pages.size() > 1, "Long VN prose was not automatically paginated")
	for page_text in long_pages:
		expect(app.dialogue_estimated_lines(page_text) <= app.DIALOGUE_PAGE_LINES, "An automatic dialogue page exceeds the line budget")

	audit_authored_dialogue(app)
	app.show_player_office()
	await process_frame
	var office_note: RichTextLabel = app.page.get_node_or_null("OfficeUsageNote")
	expect(office_note != null and office_note.scroll_active, "Non-VN office reference prose should remain scrollable")
	print("text_overflow_test: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)

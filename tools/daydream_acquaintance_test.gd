extends SceneTree
const Catalog = preload("res://godot/systems/daydream_catalog.gd")
var checks := 0
var failures := 0
func expect(ok: bool, note: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(note)
func _initialize() -> void: call_deferred("run")
func run() -> void:
	var app = load("res://godot/scenes/main.tscn").instantiate()
	root.add_child(app)
	await process_frame
	var entries := Catalog.entries()
	var casts := [["nurse_hiroko", "doc_emiko"], ["patient_chihaya"], ["guest_mizuho"]]
	for locale in ["zh_CN", "en"]:
		expect(app.content.load_all(locale), "Load " + locale)
		app.configure_game_content()
		app.game.reset()
		app.game.meet_staff("nurse_hiroko")
		app.game.meet_staff("doc_emiko")
		# Never allow a future import to introduce a romance threshold, even
		# when the current player happens to meet that threshold.
		app.game.relation_for("nurse_hiroko").level = 5
		for level in [1, 2, 3, 4, 5, 6, 0.5, "4", -1, null]:
			var forbidden: Dictionary = entries[0].duplicate(true)
			forbidden.gate = {"levels": {"nurse_hiroko": level}}
			expect(not Catalog.valid(forbidden), "Reject forbidden relationship gate: " + str(level))
			expect(not Catalog.unlocked(forbidden, app.game), "No bypass through direct gate check")
			expect(Catalog.definition(forbidden, locale).is_empty(), "Invalid gate cannot produce playback")
		for gate in [{"flags": ["romance_unlocked"]}, {"events": ["hiroko_lv4"]}, {"relationship_level": 4}]:
			var forbidden: Dictionary = entries[0].duplicate(true)
			forbidden.gate = gate
			expect(not Catalog.valid(forbidden), "No indirect relationship/event prerequisites")
		var zero: Dictionary = entries[0].duplicate(true)
		zero.gate = {"levels": {"nurse_hiroko": 0}}
		app.game.relation_for("nurse_hiroko").level = 0
		expect(Catalog.valid(zero) and Catalog.unlocked(zero, app.game), "Explicit Lv0 means acquaintance only")
		app.game.relation_for("nurse_hiroko").met = false
		expect(not Catalog.unlocked(zero, app.game), "Lv0 does not imply an unknown character is met")
		for index in range(entries.size()):
			var entry: Dictionary = entries[index]
			app.game.reset()
			expect(entry.gate == {"met": casts[index]}, "Only main-character acquaintance gates")
			expect(Catalog.valid(entry), "Complete bilingual catalog")
			for actor in casts[index]: app.game.relation_for(actor).met = false
			expect(not Catalog.unlocked(entry, app.game), "Unknown character locked")
			for actor in casts[index]:
				app.game.relation_for(actor).met = true
				app.game.relation_for(actor).level = 0
				if actor != casts[index].back():
					expect(not Catalog.unlocked(entry, app.game), "Both main characters must be known")
			var before: Dictionary = app.game.snapshot()
			expect(Catalog.unlocked(entry, app.game), "Lv0 acquaintance unlocks without surgery or recruitment")
			expect(app.game.snapshot() == before, "Gate query does not mutate persistent facts")
			app.show_player_office()
			app.daydream_view.maximum = 2
			app.daydream_view.open(app)
			await process_frame
			var button = app.find_child("DaydreamEntry_" + str(entry.id), true, false)
			expect(button is Button, "Real catalog button exists")
			if button is Button:
				expect(not button.disabled, "Real entry available at Lv0")
				expect(button.text.contains(entry.cast[locale]), "Localized names displayed")
				expect(button.tooltip_text == entry.unlock_hint[locale], "Localized acquaintance hint")
				for actor in casts[index]: expect(not button.text.contains(actor), "No technical actor ID")
				expect(not button.text.contains("verbatim") and not button.text.contains("节点导入"), "No import jargon")
			app.daydream_view.leave()
		# Story acquaintances are valid before these characters join the hospital.
		for index in [1, 2]:
			app.game.reset()
			var actor: String = casts[index][0]
			app.game.relation_for(actor).met = false
			var flag: String = "chihaya_identity_revealed" if index == 1 else "mizuho_identity_revealed"
			app.game.set_story_flag(flag, true)
			expect(not app.game.staff_is_met(actor), "Story acquaintance is not recruitment")
			expect(Catalog.unlocked(entries[index], app.game), "Named story acquaintance unlocks")
			app.game.set_story_flag(flag, false)
			expect(not Catalog.unlocked(entries[index], app.game), "No acquaintance remains locked")
		for path in OS.get_cmdline_user_args():
			var save: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
			expect(save is Dictionary and app.game.restore(save), "Read-only supplied save imports")
			for entry in entries: expect(Catalog.unlocked(entry, app.game), "Existing acquaintance in supplied save unlocks " + str(entry.id))
	app.queue_free()
	await process_frame
	print("Daydream acquaintance: %s checks, %s failures" % [checks, failures])
	quit(1 if failures else 0)

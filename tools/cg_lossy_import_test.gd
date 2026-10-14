extends SceneTree
## Verify the bounded CG compression trial without changing saves or preferences.
const MANIFEST := "res://research/imports/cg_lossy_trial_2026-10-13.json"
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
	var manifest_path := "res://research/imports/fullscreen_lossy_2026-10-13.json" if OS.get_cmdline_user_args().has("--fullscreen") else MANIFEST
	if OS.get_cmdline_user_args().has("--portraits"):
		manifest_path = "res://research/imports/portrait_lossy_trial_2026-10-13.json"
	var manifest: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(manifest_path))
	if manifest.get("portrait_scope", false):
		var probe := Image.create(2, 1, false, Image.FORMAT_RGBA8)
		probe.set_pixel(0, 0, Color(0.6, 0.2, 0.4, 0.37))
		probe.set_pixel(1, 0, Color(0.8, 0.9, 0.3, 0.83))
		var alpha0 := probe.get_pixel(0, 0).a
		var alpha1 := probe.get_pixel(1, 0).a
		probe.adjust_bcs(0.0, 1.0, 1.0)
		expect(probe.get_pixel(0, 0) == Color(0, 0, 0, alpha0) and probe.get_pixel(1, 0) == Color(0, 0, 0, alpha1), "Alpha-mask comparison preserves independently known alpha values")
	var targets: Dictionary = {}
	var before_bytes := 0
	var after_bytes := 0
	for row in manifest.assets:
		var path: String = "res://" + str(row.path)
		expect(not targets.has(row.path), "Unique trial path: " + path)
		targets[row.path] = true
		expect(FileAccess.get_sha256(path) == row.sha256, "Original PNG unchanged: " + path)
		var settings := ConfigFile.new()
		expect(settings.load(path + ".import") == OK, "Import configuration readable: " + path)
		expect(settings.get_value("params", "compress/mode") == 1, "Lossy import enabled: " + path)
		expect(is_equal_approx(float(settings.get_value("params", "compress/lossy_quality")), float(manifest.quality)), "Trial quality preserved: " + path)
		var original := Image.new()
		expect(original.load_png_from_buffer(FileAccess.get_file_as_bytes(path)) == OK, "Source PNG decodes: " + path)
		var texture = load(path)
		expect(texture is Texture2D, "Imported texture loads: " + path)
		if not texture is Texture2D or original == null:
			continue
		var decoded: Image = texture.get_image()
		expect(decoded != null, "Imported texture decodes: " + path)
		if decoded == null:
			continue
		expect(texture.get_width() == int(row.width) and texture.get_height() == int(row.height), "Texture dimensions unchanged: " + path)
		expect(original.detect_alpha() == decoded.detect_alpha(), "Transparency classification preserved: " + path)
		if manifest.get("portrait_scope", false):
			# Compare every alpha byte, not just corners or the presence of alpha.
			# Native image adjustment zeros RGB while preserving alpha; source files
			# and loaded Texture2D resources are untouched by these in-memory copies.
			original.convert(Image.FORMAT_RGBA8)
			decoded.convert(Image.FORMAT_RGBA8)
			original.adjust_bcs(0.0, 1.0, 1.0)
			decoded.adjust_bcs(0.0, 1.0, 1.0)
			expect(original.get_data() == decoded.get_data(), "Every portrait alpha byte preserved: " + path)
		before_bytes += int(row.texture_bytes_before)
		for imported in settings.get_value("deps", "dest_files", PackedStringArray()):
			var file := FileAccess.open(imported, FileAccess.READ)
			expect(file != null, "Imported payload exists: " + imported)
			if file != null:
				after_bytes += file.get_length()
				file.close()
		# Let resources be released between full-resolution source/texture pairs.
		await process_frame
		if manifest.get("portrait_scope", false) and targets.size() % 100 == 0:
			print("PORTRAIT ALPHA CHECK: ", targets.size(), "/", manifest.assets.size())
	for locale in ["zh_CN", "en"]:
		var content = load("res://godot/scripts/content_loader.gd").new()
		expect(content.load_all(locale), "Localized content loads: " + locale)
		var loaded: Dictionary = {}
		if manifest.get("portrait_scope", false):
			var inventory: Dictionary = load("res://tools/fullscreen_lossy_inventory.gd").collect(content)
			for path in inventory.protected:
				loaded[path] = true
		if manifest.has("fullscreen_groups"):
			var inventory: Dictionary = load("res://tools/fullscreen_lossy_inventory.gd").collect(content)
			for group in manifest.fullscreen_groups:
				var expected: Array = manifest.fullscreen_groups[group].duplicate()
				var actual: Array = inventory.groups[group].duplicate()
				expected.sort()
				actual.sort()
				expect(actual == expected, "Fullscreen inventory unchanged: " + locale + "/" + group)
				for path in actual:
					loaded[path] = true
			for path in inventory.protected:
				expect(not targets.has(path), "Portrait excluded from compression scope: " + path)
		for collection in manifest.get("collection_counts", {}):
			var paths: Dictionary = {}
			for pool in content.collections[collection]:
				for path in pool.paths:
					paths[path] = true
					loaded[path] = true
			expect(paths.size() == int(manifest.collection_counts[collection]), "Pool inventory unchanged: " + locale + "/" + collection)
		expect(loaded.size() == targets.size(), "No pool texture omitted: " + locale)
		for path in loaded:
			expect(targets.has(path), "Localized pool uses exact trial path: " + path)
	expect(after_bytes < before_bytes, "Imported CG storage decreased")
	print("CG LOSSY TRIAL: ", checks, " checks; ", failures, " failure(s); ", targets.size(), " PNGs; texture bytes ", before_bytes, " -> ", after_bytes)
	quit(1 if failures else 0)

extends SceneTree
## Read-only export of the authoritative loader; output must not already exist.
const Loader = preload("res://godot/scripts/content_loader.gd")

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 1 or FileAccess.file_exists(args[0]):
		push_error("Supply one unused export path after --")
		quit(2)
		return
	var content = Loader.new()
	if not content.load_all("zh_CN"):
		push_error(str(content.errors))
		quit(2)
		return
	var procedures := {}
	for surgery in content.collections.surgeries:
		procedures[surgery.id] = surgery.duplicate(true)
	var output := FileAccess.open(args[0], FileAccess.WRITE)
	if output == null:
		quit(2)
		return
	output.store_string(JSON.stringify({"source": "ContentLoader.load_all(zh_CN)", "procedures": procedures}, "\t") + "\n")
	output.close()
	print("Exported %s loaded procedures" % procedures.size())
	quit(0)

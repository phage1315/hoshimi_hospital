extends RefCounted
## Single manual save slot. Atomic replacement preserves the previous save on failure.
var path := "user://clinic_slot_1.json"
var last_error := ""

func exists() -> bool:
	return FileAccess.file_exists(path)

func write_slot(state: RefCounted) -> bool:
	last_error = ""
	if state.has_method("can_save_progress") and not state.can_save_progress():
		last_error = str(state.save_block_reason())
		return false
	var temporary := path + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "无法写入存档，现有存档未改变。"
		return false
	file.store_string(JSON.stringify(state.snapshot(), "\t"))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK:
		last_error = "存档写入未完成，现有存档未改变。"
		return false
	result = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(path))
	if result != OK:
		last_error = "无法替换存档，现有存档未改变。"
		return false
	return true

func read_slot(state: RefCounted) -> bool:
	last_error = ""
	if not exists():
		last_error = "还没有存档。请先在门诊或导览中保存。"
		return false
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null or file.get_length() > 1024 * 1024:
		last_error = "无法读取存档，当前进度未改变。"
		return false
	var parser := JSON.new()
	var result := parser.parse(file.get_as_text())
	file.close()
	if result != OK:
		last_error = "存档文件损坏，当前进度未改变。"
		return false
	if not state.restore(parser.data):
		last_error = state.last_error
		return false
	return true

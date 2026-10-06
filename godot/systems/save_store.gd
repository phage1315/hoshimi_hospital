extends RefCounted
## Eight independent manual save slots. Each slot is replaced atomically so a
## failed write cannot damage the previous save.

const SLOT_COUNT := 8
const MAX_SAVE_BYTES := 1024 * 1024
const DEFAULT_SLOT_ONE_PATH := "user://clinic_slot_1.json"

# Kept public for isolated file-I/O tests and old callers. Slot 1 deliberately
# retains the former filename, so existing single-slot saves migrate naturally.
var path := DEFAULT_SLOT_ONE_PATH
var last_error := ""

func slot_path(slot: int) -> String:
	if slot == 1:
		return path
	if path != DEFAULT_SLOT_ONE_PATH:
		var extension := path.get_extension()
		var stem := path.trim_suffix("." + extension) if not extension.is_empty() else path
		return "%s_slot_%d%s" % [stem, slot, "." + extension if not extension.is_empty() else ""]
	return "user://clinic_slot_%d.json" % slot

func valid_slot(slot: int) -> bool:
	return slot >= 1 and slot <= SLOT_COUNT

func exists(slot: int = 1) -> bool:
	return valid_slot(slot) and FileAccess.file_exists(slot_path(slot))

func any_exists() -> bool:
	for slot in range(1, SLOT_COUNT + 1):
		if exists(slot):
			return true
	return false

func _metadata_for_state(state: RefCounted, snapshot: Dictionary) -> Dictionary:
	return {
		"saved_at": Time.get_datetime_string_from_system(false, true),
		"day": int(state.day_number()) if state.has_method("day_number") else 1,
		"calendar": str(state.calendar_compact_text()) if state.has_method("calendar_compact_text") else "",
		"clock": str(state.clock_text()) if state.has_method("clock_text") else "",
		"active_mode": str(snapshot.get("active_mode", "")),
		"patient_id": str(state.current_patient_id()) if state.has_method("current_patient_id") else "",
		"completed_surgeries": int(snapshot.get("completed_surgeries_total", 0)),
	}

func write_slot(state: RefCounted, slot: int = 1) -> bool:
	last_error = ""
	if not valid_slot(slot):
		last_error = "存档位置不存在。"
		return false
	if state.has_method("can_save_progress") and not state.can_save_progress():
		last_error = str(state.save_block_reason())
		return false
	var destination := slot_path(slot)
	var temporary := destination + ".tmp"
	var file := FileAccess.open(temporary, FileAccess.WRITE)
	if file == null:
		last_error = "无法写入存档，现有存档未改变。"
		return false
	var snapshot: Dictionary = state.snapshot()
	snapshot["_slot_metadata"] = _metadata_for_state(state, snapshot)
	file.store_string(JSON.stringify(snapshot, "\t"))
	file.flush()
	var result := file.get_error()
	file.close()
	if result != OK:
		last_error = "存档写入未完成，现有存档未改变。"
		return false
	result = DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary), ProjectSettings.globalize_path(destination))
	if result != OK:
		last_error = "无法替换存档，现有存档未改变。"
		return false
	return true

func _read_data(slot: int) -> Variant:
	if not valid_slot(slot) or not exists(slot):
		return null
	var file := FileAccess.open(slot_path(slot), FileAccess.READ)
	if file == null or file.get_length() > MAX_SAVE_BYTES:
		if file != null:
			file.close()
		return null
	var parser := JSON.new()
	var result := parser.parse(file.get_as_text())
	file.close()
	if result != OK or not parser.data is Dictionary:
		return null
	return parser.data

func slot_summary(slot: int) -> Dictionary:
	if not exists(slot):
		return {"exists": false, "slot": slot}
	var data: Variant = _read_data(slot)
	if data == null:
		return {"exists": true, "valid": false, "slot": slot}
	var metadata: Dictionary = data.get("_slot_metadata", {})
	return {
		"exists": true,
		"valid": true,
		"slot": slot,
		"saved_at": str(metadata.get("saved_at", "旧版存档")),
		"day": int(metadata.get("day", 0)),
		"calendar": str(metadata.get("calendar", "")),
		"clock": str(metadata.get("clock", "")),
		"active_mode": str(metadata.get("active_mode", data.get("active_mode", ""))),
		"patient_id": str(metadata.get("patient_id", "")),
		"completed_surgeries": int(metadata.get("completed_surgeries", data.get("completed_surgeries_total", 0))),
	}

func read_slot(state: RefCounted, slot: int = 1) -> bool:
	last_error = ""
	if not valid_slot(slot):
		last_error = "存档位置不存在。"
		return false
	if not exists(slot):
		last_error = "这个位置还没有存档。"
		return false
	var data: Variant = _read_data(slot)
	if data == null:
		last_error = "存档文件损坏，当前进度未改变。"
		return false
	if not state.restore(data):
		last_error = state.last_error
		return false
	return true

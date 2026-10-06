extends RefCounted
## Lightweight localization service for authored JSON and hard-coded UI chrome.
## Chinese source text remains the canonical fallback, so incomplete locales are
## always playable while translations are added incrementally.

const DEFAULT_LOCALE: String = "zh_CN"
const SUPPORTED_LOCALES: Array[String] = ["zh_CN", "en"]
const SETTINGS_PATH: String = "user://settings.cfg"

var locale: String = DEFAULT_LOCALE
var strings: Dictionary = {}
var errors: Array[String] = []

func normalize_locale(value: String) -> String:
	var candidate: String = value.strip_edges().replace("-", "_")
	if candidate.begins_with("zh"):
		return DEFAULT_LOCALE
	if candidate.begins_with("en"):
		return "en"
	return DEFAULT_LOCALE

func preferred_locale() -> String:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return DEFAULT_LOCALE
	return normalize_locale(str(config.get_value("localization", "locale", DEFAULT_LOCALE)))

func save_preference() -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("localization", "locale", locale)
	return config.save(SETTINGS_PATH) == OK

func preferred_intraoperative_crisis_enabled() -> bool:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return true
	return bool(config.get_value("gameplay", "intraoperative_crisis_enabled", true))

func save_intraoperative_crisis_preference(enabled: bool) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("gameplay", "intraoperative_crisis_enabled", enabled)
	return config.save(SETTINGS_PATH) == OK

func preferred_operative_field_hud_enabled() -> bool:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return false
	return bool(config.get_value("gameplay", "operative_field_hud_enabled", false))

func save_operative_field_hud_preference(enabled: bool) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("gameplay", "operative_field_hud_enabled", enabled)
	return config.save(SETTINGS_PATH) == OK

func preferred_dialogue_auto_speed() -> int:
	var config: ConfigFile = ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return 1
	return clampi(int(config.get_value("dialogue", "auto_speed", 1)), 0, 3)

func save_dialogue_auto_speed(speed_index: int) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("dialogue", "auto_speed", clampi(speed_index, 0, 3))
	return config.save(SETTINGS_PATH) == OK

func load_locale(requested_locale: String = DEFAULT_LOCALE) -> bool:
	errors.clear()
	strings.clear()
	locale = normalize_locale(requested_locale)
	TranslationServer.set_locale(locale)
	if locale == DEFAULT_LOCALE:
		return true
	var path: String = "res://data/localization/%s.json" % locale
	if not FileAccess.file_exists(path):
		errors.append("翻译文件不存在：" + path)
		return false
	var parser: JSON = JSON.new()
	if parser.parse(FileAccess.get_file_as_string(path)) != OK:
		errors.append("翻译 JSON 错误：%s / 行 %s" % [path, parser.get_error_line()])
		return false
	if not parser.data is Dictionary or not parser.data.get("strings") is Dictionary:
		errors.append("翻译文件格式无效：" + path)
		return false
	if normalize_locale(str(parser.data.get("locale", ""))) != locale:
		errors.append("翻译文件语言与文件名不一致：" + path)
		return false
	strings = parser.data.strings.duplicate(true)
	return true

func text(key: String, fallback: String, replacements: Dictionary = {}) -> String:
	var result: String = fallback
	if locale != DEFAULT_LOCALE and strings.has(key) and not str(strings[key]).is_empty():
		result = str(strings[key])
	for name in replacements:
		result = result.replace("{" + str(name) + "}", str(replacements[name]))
	return result

func localize_tree(value: Variant, key: String) -> Variant:
	if value is Dictionary:
		var localized: Dictionary = {}
		for field in value:
			localized[field] = localize_tree(value[field], key + "." + str(field))
		return localized
	if value is Array:
		var localized: Array = []
		for index in range(value.size()):
			var entry: Variant = value[index]
			var identity: String = str(index)
			if entry is Dictionary and not str(entry.get("id", "")).is_empty():
				identity = str(entry.id)
			localized.append(localize_tree(entry, key + "." + identity))
		return localized
	if value is String:
		return text(key, value)
	return value

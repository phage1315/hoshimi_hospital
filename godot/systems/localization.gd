extends RefCounted
## Lightweight localization service for authored JSON and hard-coded UI chrome.
## Chinese source text is canonical for zh_CN. A missing English translation
## is reported visibly rather than silently showing Chinese in English mode.

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
		return true
	return bool(config.get_value("gameplay", "operative_field_hud_enabled", true))

func save_operative_field_hud_preference(enabled: bool) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(SETTINGS_PATH)
	config.set_value("gameplay", "operative_field_hud_enabled", enabled)
	return config.save(SETTINGS_PATH) == OK

func preferred_dialogue_auto_speed(settings_path: String = SETTINGS_PATH) -> int:
	var config: ConfigFile = ConfigFile.new()
	if config.load(settings_path) != OK:
		return 1
	return clampi(int(config.get_value("dialogue", "auto_speed", 1)), 0, 4)

func save_dialogue_auto_speed(speed_index: int, settings_path: String = SETTINGS_PATH) -> bool:
	var config: ConfigFile = ConfigFile.new()
	config.load(settings_path)
	config.set_value("dialogue", "auto_speed", clampi(speed_index, 0, 4))
	return config.save(settings_path) == OK

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
	if locale != DEFAULT_LOCALE:
		if strings.has(key) and not str(strings[key]).strip_edges().is_empty() and not _contains_cjk(str(strings[key])):
			result = str(strings[key])
		elif _contains_cjk(fallback) or key.begins_with("ui."):
			result = _missing_translation(key)
	for name in replacements:
		result = result.replace("{" + str(name) + "}", str(replacements[name]))
	return result

func _contains_cjk(value: String) -> bool:
	for index in range(value.length()):
		var code := value.unicode_at(index)
		if (code >= 0x3400 and code <= 0x9FFF) or (code >= 0x3040 and code <= 0x30FF):
			return true
	return false

func _missing_translation(key: String) -> String:
	var message := "Missing translation: " + key
	if not errors.has(message):
		errors.append(message)
	return "[MISSING TRANSLATION: %s]" % key

func identifier_title(identifier: String) -> String:
	var words := identifier.trim_prefix("surgery_").replace("_", " ").split(" ")
	var result := ""
	for word in words:
		if word.is_empty():
			continue
		result += (" " if not result.is_empty() else "") + word.capitalize()
	return result if not result.is_empty() else "Surgical Stage"

func localize_tree(value: Variant, key: String) -> Variant:
	if value is Dictionary:
		if value.has("zh_CN") and value.zh_CN is String:
			if locale == DEFAULT_LOCALE:
				return str(value.zh_CN)
			if value.has(locale) and value[locale] is String and not str(value[locale]).strip_edges().is_empty() and not _contains_cjk(str(value[locale])):
				return str(value[locale])
			return _missing_translation(key)
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
		# Role rewards contain routing IDs and an asset path as well as prose.
		# Only their authored display fields may pass through translation, even
		# if a locale file accidentally contains a key for a technical field.
		if key.begins_with("collections.staff_role_cg_rewards."):
			var field := key.get_slice(".", key.get_slice_count(".") - 1)
			if field not in ["title", "caption"]:
				return value
		return text(key, value)
	return value

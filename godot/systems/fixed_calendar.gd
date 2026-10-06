extends RefCounted

const START_YEAR := 2025
const START_MONTH := 4
const START_DAY := 1
const GAME_DAYS := 365
const WEEKDAY_NAMES := ["周一", "周二", "周三", "周四", "周五", "周六", "周日"]
const WEEKDAY_IDS := ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
const MONTH_LENGTHS_2025 := [30, 31, 30, 31, 31, 30, 31, 30, 31]
const MONTH_LENGTHS_2026 := [31, 28, 31, 30]

const PUBLIC_HOLIDAYS := {
	"2025-04-29": "昭和之日",
	"2025-05-03": "宪法纪念日",
	"2025-05-04": "绿之日",
	"2025-05-05": "儿童节",
	"2025-05-06": "补休",
	"2025-07-21": "海之日",
	"2025-08-11": "山之日",
	"2025-09-15": "敬老之日",
	"2025-09-23": "秋分之日",
	"2025-10-13": "体育之日",
	"2025-11-03": "文化之日",
	"2025-11-23": "勤劳感谢之日",
	"2025-11-24": "补休",
	"2026-01-01": "元旦",
	"2026-01-12": "成人之日",
	"2026-02-11": "建国纪念日",
	"2026-02-23": "天皇诞生日",
	"2026-03-20": "春分之日",
}

static func iso_date(year: int, month: int, date: int) -> String:
	return "%04d-%02d-%02d" % [year, month, date]

static func date_for_day(day_number: int) -> Dictionary:
	var safe_day := clampi(day_number, 1, GAME_DAYS + 1)
	var remaining := safe_day - 1
	var year := START_YEAR
	var month := START_MONTH
	var month_lengths := MONTH_LENGTHS_2025
	while true:
		var month_index := month - (4 if year == 2025 else 1)
		if month_index >= month_lengths.size():
			year = 2026
			month = 1
			month_lengths = MONTH_LENGTHS_2026
			continue
		var length: int = month_lengths[month_index]
		if remaining < length:
			break
		remaining -= length
		month += 1
	var date := remaining + 1
	var weekday_index := (1 + safe_day - 1) % 7 # 2025-04-01 is Tuesday.
	var iso := iso_date(year, month, date)
	return {
		"year": year,
		"month": month,
		"date": date,
		"iso": iso,
		"weekday_index": weekday_index,
		"weekday_id": WEEKDAY_IDS[weekday_index],
		"weekday_name": WEEKDAY_NAMES[weekday_index],
		"holiday_name": holiday_name_for_iso(iso),
		"day_type": day_type_for(safe_day),
	}

static func day_for_iso(value: String) -> int:
	var parts := value.split("-")
	if parts.size() != 3:
		return -1
	var year := int(parts[0])
	var month := int(parts[1])
	var date := int(parts[2])
	if year == 2025 and month >= 4 and month <= 12:
		var result := date
		for index in range(month - 4):
			result += MONTH_LENGTHS_2025[index]
		return result if date >= 1 and date <= MONTH_LENGTHS_2025[month - 4] else -1
	if year == 2026 and month >= 1 and month <= 4:
		var result := 275 + date
		for index in range(month - 1):
			result += MONTH_LENGTHS_2026[index]
		return result if date >= 1 and date <= MONTH_LENGTHS_2026[month - 1] else -1
	return -1

static func holiday_name_for_iso(value: String) -> String:
	if PUBLIC_HOLIDAYS.has(value):
		return str(PUBLIC_HOLIDAYS[value])
	var day := day_for_iso(value)
	if day >= day_for_iso("2025-12-29") and day <= day_for_iso("2026-01-03"):
		return "年末年初休诊"
	return ""

static func day_type_for(day_number: int) -> String:
	var data := date_for_day_without_type(day_number)
	var iso := str(data.iso)
	if PUBLIC_HOLIDAYS.has(iso):
		return "public_holiday"
	var closure_start := day_for_iso("2025-12-29")
	var closure_end := day_for_iso("2026-01-03")
	if day_number >= closure_start and day_number <= closure_end:
		return "hospital_holiday"
	match int(data.weekday_index):
		5:
			return "saturday"
		6:
			return "sunday"
		_:
			return "weekday"

static func date_for_day_without_type(day_number: int) -> Dictionary:
	var safe_day := clampi(day_number, 1, GAME_DAYS + 1)
	var remaining := safe_day - 1
	var year := START_YEAR
	var month := START_MONTH
	var month_lengths := MONTH_LENGTHS_2025
	while true:
		var month_index := month - (4 if year == 2025 else 1)
		if month_index >= month_lengths.size():
			year = 2026
			month = 1
			month_lengths = MONTH_LENGTHS_2026
			continue
		var length: int = month_lengths[month_index]
		if remaining < length:
			break
		remaining -= length
		month += 1
	var date := remaining + 1
	var weekday_index := (1 + safe_day - 1) % 7
	return {"year": year, "month": month, "date": date, "iso": iso_date(year, month, date), "weekday_index": weekday_index}

static func is_routine_workday(day_number: int) -> bool:
	return day_type_for(day_number) == "weekday"

static func is_limited_workday(day_number: int) -> bool:
	return day_type_for(day_number) == "saturday"

static func is_closed_day(day_number: int) -> bool:
	return day_type_for(day_number) in ["sunday", "public_holiday", "hospital_holiday"]

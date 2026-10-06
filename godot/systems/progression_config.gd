extends RefCounted

# Central balance configuration for the canonical five-dimension system.
const PLAYER_ATTRIBUTE_BASE := {
	"skill": 50,
	"leadership": 50,
	"charm": 0,
	"reputation": 0,
	"presence": 0,
}
const PLAYER_ATTRIBUTE_MIN := {
	"skill": 50,
	"leadership": 50,
	"charm": 0,
	"reputation": -999,
	"presence": -200,
}
const PLAYER_ATTRIBUTE_MAX := {
	"skill": 100,
	"leadership": 100,
	"charm": 2147483647,
	"reputation": 999,
	"presence": 200,
}

const CHARM_TIERS := [
	{"minimum": 0, "label": "平常"},
	{"minimum": 20, "label": "得体"},
	{"minimum": 50, "label": "出众"},
	{"minimum": 100, "label": "迷人"},
	{"minimum": 170, "label": "非凡"},
]
const PRESENCE_TIERS := [
	{"minimum": -200, "label": "可亲型"},
	{"minimum": -169, "label": "温和型"},
	{"minimum": -59, "label": "平衡型"},
	{"minimum": 60, "label": "强势型"},
	{"minimum": 170, "label": "威压型"},
]
const PRESENCE_PHASE_CLAMPS := {"encounter": 1, "preop": 1, "or": 2}

const REPUTATION_PROFILES := {
	"simple": {"label": "简单", "award": 2, "soft_cap": 80, "cap": 100},
	"standard": {"label": "普通", "award": 2, "soft_cap": 240, "cap": 300},
	"advanced": {"label": "高级", "award": 40, "soft_cap": 480, "cap": 600},
	"extreme": {"label": "极难", "award": 75, "soft_cap": 800, "cap": 999},
}
const NO_ANESTHESIA_REPUTATION_PENALTY := -10
const WRONG_PROCEDURE_REPUTATION_PENALTY := -75

const LEADERSHIP_START_LEVEL := 50
const LEADERSHIP_MAX_LEVEL := 100
const LEADERSHIP_XP_BASE := 8.0
const LEADERSHIP_XP_GROWTH := 1.02
const LEADERSHIP_CASE_BASE := {
	"simple": 1.0,
	"standard": 2.0,
	"advanced": 8.0,
	"extreme": 12.0,
	"legendary": 16.0,
}
const LEADERSHIP_TEAM_CLASSES := [
	{"minimum": 86.0, "id": "strong", "multiplier": 0.5},
	{"minimum": 70.0, "id": "normal", "multiplier": 1.0},
	{"minimum": -1.0, "id": "developing", "multiplier": 1.5},
]
const TEAM_SURGERY_XP_MULTIPLIERS := [
	{"minimum": 90.0, "multiplier": 1.15},
	{"minimum": 80.0, "multiplier": 1.10},
	{"minimum": 70.0, "multiplier": 1.06},
	{"minimum": 60.0, "multiplier": 1.03},
	{"minimum": -1.0, "multiplier": 1.00},
]

const FAMILIARITY_CASE_BASE := {"routine": 5, "advanced": 10, "extreme": 15}
const DATE_FAMILIARITY_BASE := 10
const RELATIONSHIP_EVENT_FAMILIARITY_BASE := {1: 10, 2: 10, 3: 12, 4: 15, 5: 20}
const RELATIONSHIP_DEFAULT_COOLDOWN_DAYS := 3

const ADVANCED_REFERRAL_UNLOCK_SURGERY := 80
const ADVANCED_REFERRAL_UNLOCK_REPUTATION := 250

static func tier_label(value: int, tiers: Array) -> String:
	var result := str(tiers[0].label)
	for tier in tiers:
		if value >= int(tier.minimum):
			result = str(tier.label)
	return result

static func charm_tier(value: int) -> String:
	return tier_label(maxi(0, value), CHARM_TIERS)

static func presence_tier(value: int) -> String:
	return tier_label(clampi(value, -200, 200), PRESENCE_TIERS)

static func reputation_tier(difficulty: int) -> String:
	if difficulty < 50:
		return "simple"
	if difficulty < 75:
		return "standard"
	if difficulty < 90:
		return "advanced"
	return "extreme"

static func leadership_team_class(team_average: float) -> Dictionary:
	for definition in LEADERSHIP_TEAM_CLASSES:
		if team_average >= float(definition.minimum):
			return definition
	return LEADERSHIP_TEAM_CLASSES.back()

static func team_surgery_xp_multiplier(team_average: float) -> float:
	for definition in TEAM_SURGERY_XP_MULTIPLIERS:
		if team_average >= float(definition.minimum):
			return float(definition.multiplier)
	return 1.0

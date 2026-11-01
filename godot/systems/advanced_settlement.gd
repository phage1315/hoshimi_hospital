extends RefCounted
## A reward input, not a session snapshot. Uses existing progression resolvers.
var procedure_id := ""
var procedure_name := ""
var team: Dictionary = {}
var definition: Dictionary = {}
var procedure_corrections := 0
var procedure_mismatch := false
var sensory_interaction_xp_bonus := 0
var surgery_success := true
var flags: Array = []

func is_staff_patient() -> bool: return false
func pilot_surgery() -> bool: return false

func settle(game: RefCounted, procedure: Dictionary, selected: Dictionary) -> Dictionary:
	procedure_id = str(procedure.id)
	procedure_name = str(procedure.name)
	team = selected.duplicate(true)
	var xp: int = game.award_surgery_xp(self, procedure)
	var leadership: float = game.award_leadership_xp(self, "advanced")
	game.train_surgery_team(team, procedure_id, "advanced")
	var profile: Dictionary = game.Progression.REPUTATION_PROFILES.advanced.duplicate(true)
	profile["base"] = profile.award
	profile["tier"] = "advanced"
	var reputation: int = game.award_surgery_reputation(procedure_id, procedure_name, self, profile)
	game.persist_shared_surgery_counts(team)
	game.award_surgery_team_familiarity(team, "advanced")
	game.completed_surgeries_total += 1
	game.completed_surgeries_by_procedure[procedure_id] = int(game.completed_surgeries_by_procedure.get(procedure_id, 0)) + 1
	return {"surgery_xp": xp, "leadership_xp": leadership, "reputation": reputation}

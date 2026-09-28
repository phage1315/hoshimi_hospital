extends RefCounted
## Shared full-screen CG pool used after the first incision is made.
const IDS := [
	"operating_team_01",
	"operating_team_02",
	"operating_team_03",
	"operating_team_04",
	"operating_team_05",
	"operating_team_06",
]

static func random_id() -> String:
	return str(IDS.pick_random())

static func valid(id: String) -> bool:
	return id in IDS

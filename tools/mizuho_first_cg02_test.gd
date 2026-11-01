extends "res://tools/mizuho_first_cg08_test.gd"

# Play from the genuine surgery-day entry: recheck CG08, then CG02 and its exit.
func node_sequence() -> Array[String]:
	var ids: Array[String]=[]
	for i in range(1,50):ids.append("b01_%03d" % i)
	for i in range(1,33):ids.append("b02_%03d" % i)
	return ids

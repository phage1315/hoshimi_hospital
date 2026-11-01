extends "res://tools/mizuho_first_cg08_test.gd"

# Actual surgery-day entry through CG08, CG02, CG03 and its return to portraits.
func node_sequence() -> Array[String]:
	var ids: Array[String]=[]
	for i in range(1,50):ids.append("b01_%03d" % i)
	for i in range(1,53):ids.append("b02_%03d" % i)
	for i in range(1,33):ids.append("b03_%03d" % i)
	return ids

extends "res://tools/mizuho_first_cg08_test.gd"

func node_sequence() -> Array[String]:
	var ids: Array[String]=[]
	for i in range(1,50):ids.append("b01_%03d" % i)
	for i in range(1,53):ids.append("b02_%03d" % i)
	for i in range(1,54):ids.append("b03_%03d" % i)
	for i in range(1,19):ids.append("b04_%03d" % i)
	return ids

func inspect_frame(node: Dictionary, locale: String, gallery: bool, first_page: bool) -> void:
	if not native or node.id!="b04_013" or not first_page:return
	await RenderingServer.frame_post_draw
	var stem: String=QA+"cg09_"+locale+("_gallery" if gallery else "_main")
	expect(root.get_texture().get_image().save_png(stem+".png")==OK,"Native CG09 overlap screenshot")
	var cg=app.page.get_node("CharacterEventCG")
	# Record controls drawn after the CG, so visual review can verify overlap.
	var overlay: Array=[]
	for child in app.page.get_children():
		if child is Control and child.get_index()>cg.get_index() and child.is_visible_in_tree():
			overlay.append({"name":child.name,"rect":str(child.get_global_rect()),"type":child.get_class()})
	var file=FileAccess.open(stem+"_layout.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"cg_rect":str(cg.get_global_rect()),"texture_size":str(cg.texture.get_size()),"overlay":overlay},"  "));file.close()

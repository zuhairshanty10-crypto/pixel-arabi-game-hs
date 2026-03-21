extends SceneTree
func _init():
	var files = ["Idle", "Attack3", "Attack5", "Attack7_body", "Special"]
	for f in files:
		var tex = load("res://assets/island4/enemies/RealBoss/" + f + ".png")
		if tex:
			var img = tex.get_image()
			# save first frame (256x256)
			var crop = Image.create(256, 256, false, Image.FORMAT_RGBA8)
			crop.blit_rect(img, Rect2(0, 0, 256, 256), Vector2(0,0))
			crop.save_png("res://boss_analysis_" + f + ".png")
			print("Saved " + f)
	quit()

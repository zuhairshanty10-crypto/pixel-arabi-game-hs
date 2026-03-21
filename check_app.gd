extends SceneTree

func _init():
	var tex = load('res://assets/island4/enemies/RealBoss/Appearance.png')
	if tex:
		var img = tex.get_image()
		var left_pixels = 0
		var right_pixels = 0
		var w = img.get_width() / 8
		var h = img.get_height()
		# check frame 7 (fully appeared)
		for x in range(w*7, w*7 + w*0.3):
			for y in range(h*0.6, h):
				if img.get_pixel(x, y).a > 0: left_pixels += 1
		print("Appearance Frame 7: Left=" + str(left_pixels))
	quit()

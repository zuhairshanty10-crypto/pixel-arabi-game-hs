extends SceneTree

func _init():
	var files = ["Idle", "Attack3", "Attack5", "Attack7_body", "Special"]
	for f in files:
		var n = "res://boss_analysis_" + f + ".png"
		var img = Image.new()
		var err = img.load(n)
		if err == OK:
			var left_pixels = 0
			var right_pixels = 0
			var w = img.get_width()
			var h = img.get_height()
			
			for x in range(0, int(w*0.3)):
				for y in range(int(h*0.6), h):
					if img.get_pixel(x, y).a > 0: left_pixels += 1
					
			for x in range(int(w*0.7), w):
				for y in range(int(h*0.6), h):
					if img.get_pixel(x, y).a > 0: right_pixels += 1
					
			print(f + ": Left=" + str(left_pixels) + ", Right=" + str(right_pixels))
	quit()

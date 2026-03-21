@tool
extends SceneTree

func _init():
	var img = Image.load_from_file("res://assets/island2/traps/Arrow_Trap/Arrow Trap - Level 1.png")
	var hframes = 51
	var frameW = img.get_width() / hframes
	var frameH = img.get_height()
	
	var visible_frames = []
	
	for f in range(hframes):
		var startX = f * frameW
		var hasPixels = false
		for y in range(frameH):
			for x in range(frameW):
				var pixel = img.get_pixel(startX + x, y)
				if pixel.a > 0.05:
					hasPixels = true
					break
			if hasPixels:
				break
		if hasPixels:
			visible_frames.append(f)
			
	print("VISIBLE FRAMES: ", visible_frames)
	quit()
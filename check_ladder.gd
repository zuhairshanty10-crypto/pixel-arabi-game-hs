extends SceneTree

func _init():
	var ladder_image = Image.load_from_file("res://assets/island3/tiles/ladder.png")
	if not ladder_image:
		print("Failed to load ladder.png")
		quit()
		return
	var opaque = 0
	for y in range(ladder_image.get_height()):
		for x in range(ladder_image.get_width()):
			if ladder_image.get_pixel(x, y).a > 0.0:
				opaque += 1
	print("Opaque pixels: ", opaque)
	quit()

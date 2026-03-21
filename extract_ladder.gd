extends SceneTree

func _init():
	var original_image = Image.load_from_file("res://assets/island3/tiles/Medieval_props_free.png")
	var ladder_image = original_image.get_region(Rect2i(196, 95, 24, 74))
	ladder_image.save_png("res://assets/island3/tiles/ladder.png")
	print("Extracted real ladder.png successfully!")
	quit()

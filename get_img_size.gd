extends SceneTree

func _init():
	var img = Image.new()
	var err = img.load("res://assets/player/Ledge_Grab.png")
	var size = img.get_size()
	var file = FileAccess.open("user://img_size.txt", FileAccess.WRITE)
	file.store_string(str(size.x) + "," + str(size.y))
	file.close()
	quit()

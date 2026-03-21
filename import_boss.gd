extends SceneTree

func _init():
	# Force Godot to scan the new directory and create .import files
	var dir = DirAccess.open("res://assets/island4/enemies/RealBoss/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".png"):
				# Loading the resource forces Godot to generate the .import file if missing
				var res = ResourceLoader.load("res://assets/island4/enemies/RealBoss/" + file_name)
				if res:
					print("Imported: " + file_name)
			file_name = dir.get_next()
	print("ASSETS IMPORTED")
	quit()

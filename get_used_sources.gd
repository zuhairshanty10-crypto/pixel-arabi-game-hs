@tool
extends SceneTree

func _init():
	var dir = DirAccess.open("res://scenes/levels/")
	if not dir:
		print("Could not open levels dir")
		quit()
		return
	
	var sources_used = {}
	dir.list_dir_begin()
	while true:
		var file_name = dir.get_next()
		if file_name == "":
			break
		if file_name.begins_with("Level_0") and file_name.ends_with(".tscn"):
			print("Checking ", file_name)
			var file = FileAccess.open("res://scenes/levels/" + file_name, FileAccess.READ)
			var content = file.get_as_text()
			
			var lines = content.split("\n")
			for line in lines:
				if line.begins_with("tile_data = PackedInt32Array("):
					var data_str = line.replace("tile_data = PackedInt32Array(", "").replace(")", "")
					var vals = data_str.split(",")
					for i in range(0, vals.size(), 3):
						if i+2 >= vals.size(): break
						var param_b = vals[i+1].to_int()
						# Source ID is the upper 16 bits of the tile ID, or the param_b value
						# Actually in Godot 4, the source_id is the upper 16 bits of param_b
						var src_id = (param_b >> 16) & 0xFFFF
						# Wait, looking at Godot 4 docs:
						# tile_data: [cell_coords.x, cell_coords.y, source_id | (atlas_coords.x << 16), atlas_coords.y | (alternative_tile << 16)]
						# Wait, the format in text resources is usually:
						# [index_x_y (as one int), source_id_and_atlas_x, atlas_y_and_alt]
						
						# Let's just collect all unique values of param_b to see the spread
						sources_used[param_b] = true
	print("SOURCES PARAM_B USED ACROSS ISLAND 1:")
	var keys = sources_used.keys()
	keys.sort()
	print(keys)
	
	print("\nExtracted specific Source IDs:")
	var actual_sources = {}
	for k in keys:
		var src_id = k & 0xFFFF
		actual_sources[src_id] = true
	var src_keys = actual_sources.keys()
	src_keys.sort()
	print(src_keys)
	quit()

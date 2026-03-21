@tool
extends SceneTree

func _init():
	print("Starting Godot 3 to 4 Combined TileSet Generator...")
	
	# In Godot 3, a TileSet could contain multiple textures, each assigned to a different integer ID.
	# The TileMap stored these IDs directly.
	# During Godot 3 -> 4 migration, Godot 4 converts the old integer tile ID into a Vector2i atlas coordinate
	# assuming it's from a single source (usually assigned Source ID 0).
	# The formula it uses is:
	# atlas_x = old_id % (texture_width / 32)
	# atlas_y = old_id / (texture_width / 32)
	# This ONLY works if the Godot 3 TileSet was a single image! 
	# If it was multiple images, the old IDs might be all over the place, but Godot 4 forces them into Source 0.
	
	# However, looking at the Tiled JSON `tileset_inventory.json`, perhaps the map WAS exported correctly
	# with the exact atlas coords expected!
	# Let's inspect `tileset_inventory.json` again. It has keys "55", "56", etc.
	# Wait! The Tiled map had "First GID" values.
	# Tileset.png might be GID 1 to 196. (It's 14x14 = 196 tiles).
	# Objects.png might be GID 197+? 
	# No, Tiled to Godot importer might have translated GID -> Godot 3 Tile ID -> Godot 4 Atlas Coords incorrectly!
	
	# Let's find out what's the maximum X and Y coords requested by `Level_01.tscn` to determine the assumed grid size.
	var scene = ResourceLoader.load("res://scenes/levels/Level_01.tscn")
	var instance = scene.instantiate()
	
	var max_atlas_x = 0
	var max_atlas_y = 0
	
	var all_atlas = {}
	
	var check_layer = func(node_name):
		var layer = instance.get_node(node_name)
		if layer:
			for pos in layer.get_used_cells():
				var atlas = layer.get_cell_atlas_coords(pos)
				all_atlas[atlas] = true
				if atlas.x > max_atlas_x: max_atlas_x = atlas.x
				if atlas.y > max_atlas_y: max_atlas_y = atlas.y
				
	check_layer.call("TileMapLayer")
	check_layer.call("Decorations")
	
	print("Max atlas coords used in Level 01: (", max_atlas_x, ", ", max_atlas_y, ")")
	
	# Print all used atlas coords
	var keys = all_atlas.keys()
	# Sort them by Y, then X
	keys.sort_custom(func(a,b):
		if a.y == b.y: return a.x < b.x
		return a.y < b.y
	)
	var dict_str = ""
	for k in keys:
		dict_str += str(k) + ", "
	print("Atlas Coords Used: ", dict_str)
	quit()

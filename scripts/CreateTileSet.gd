@tool
extends EditorScript

# This script auto-generates a TileSet resource from individual images.
# Run this from the Godot Editor by File -> Run (Ctrl+Shift+X) when this script is open.

func _run() -> void:
	var tileset = TileSet.new()
	# Use exactly 48x48 so tiles attach seamlessly when drawing
	tileset.tile_size = Vector2i(48, 48)
	
	# Add a physics layer for collision
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 1) # Layer 1 = World
	tileset.set_physics_layer_collision_mask(0, 0)
	
	var dir = DirAccess.open("res://assets/tiles")
	if not dir:
		print("Failed to open tiles directory")
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var id_counter = 0
	
	while file_name != "":
		if file_name.ends_with(".png") and not file_name.ends_with(".import"):
			var texture_path = "res://assets/tiles/" + file_name
			var texture = load(texture_path)
			
			if texture:
				var tex_size = texture.get_size()
				var source = TileSetAtlasSource.new()
				source.texture = texture
				source.texture_region_size = tex_size
				
				# Add source to tileset FIRST, so it inherits the physics layer definitions
				tileset.add_source(source, id_counter)
				
				# Create the tile at coordinate 0,0 in this source
				source.create_tile(Vector2i(0, 0))
				
				# The actual image is 48x48, but the grid is 64x64.
				# Godot centers the 48x48 image inside the 64x64 cell.
				# Collision is relative to the center of the 64x64 cell (0,0).
				# We want a 48x48 collision box that aligns exactly with the visual texture.
				var tile_data = source.get_tile_data(Vector2i(0, 0), 0)
				if tile_data:
					tile_data.add_collision_polygon(0)
					
					# Since texture is 48x48, its visual coordinates relative to the 64x64 cell center are:
					# Left: -24, Right: 24, Top: -24, Bottom: 24
					# However, the grass art has ~4 pixels of empty space at the top.
					# So the solid part starts around Y = -20 and ends at Y = 24.
					tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
						Vector2(-24, -20),
						Vector2(24, -20),
						Vector2(24, 24),
						Vector2(-24, 24)
					]))
				
				id_counter += 1
				
		file_name = dir.get_next()
		
	var save_path = "res://resources/tilesets/forest_tileset.tres"
	var err = ResourceSaver.save(tileset, save_path)
	if err == OK:
		print("Successfully generated TileSet at: ", save_path)
		print("Created ", id_counter, " tiles.")
	else:
		print("Error saving TileSet: ", err)

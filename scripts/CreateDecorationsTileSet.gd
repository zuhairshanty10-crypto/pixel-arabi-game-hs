@tool
extends EditorScript

# Auto-generates a TileSet for decorations (trees, rocks, bushes) without collision.
func _run() -> void:
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(48, 48)
	
	var dir = DirAccess.open("res://assets/objects")
	if not dir:
		print("Failed to open objects directory")
		return
		
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var id_counter = 0
	
	while file_name != "":
		if file_name.ends_with(".png") and not file_name.ends_with(".import"):
			var texture_path = "res://assets/objects/" + file_name
			var texture = load(texture_path)
			
			if texture:
				var tex_size = texture.get_size()
				var source = TileSetAtlasSource.new()
				source.texture = texture
				source.texture_region_size = tex_size
				
				# Add source to tileset
				tileset.add_source(source, id_counter)
				
				# Create the tile
				source.create_tile(Vector2i(0, 0))
				
				# We intentionally DO NOT add collision here, so the player can walk past decorations
				
				id_counter += 1
				
		file_name = dir.get_next()
		
	var save_path = "res://resources/tilesets/decorations_tileset.tres"
	var err = ResourceSaver.save(tileset, save_path)
	if err == OK:
		print("Successfully generated Decorations TileSet at: ", save_path)
		print("Created ", id_counter, " decoration tiles.")
	else:
		print("Error saving Decorations TileSet: ", err)

@tool
extends EditorScript

# Auto-generates a TileSet from the Island 3 Objects.png spritesheet.
func _run() -> void:
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	
	var texture = load("res://assets/island3/Objects.png")
	if not texture:
		print("Error: Could not find Island 3 Objects.png")
		return
		
	var source = TileSetAtlasSource.new()
	source.texture = texture
	source.texture_region_size = Vector2i(32, 32)
	
	tileset.add_source(source, 0)
	
	var tex_size = texture.get_size()
	var cols = int(tex_size.x / 32)
	var rows = int(tex_size.y / 32)
	
	var tiles_created = 0
	
	# Iterate over every 32x32 grid cell in the spritesheet
	for y in range(rows):
		for x in range(cols):
			var coords = Vector2i(x, y)
			source.create_tile(coords)
			tiles_created += 1

	var save_path = "res://resources/tilesets/island3_decorations_tileset.tres"
	var err = ResourceSaver.save(tileset, save_path)
	if err == OK:
		print("Successfully generated Island 3 Decorations TileSet at: ", save_path)
		print("Created ", tiles_created, " tiles.")
	else:
		print("Error saving Decorations TileSet: ", err)

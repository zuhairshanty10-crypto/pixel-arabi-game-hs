@tool
extends SceneTree

func _init():
	print("Building Island 3 Tilesets...")
	
	# 1. Main Tileset
	var main_ts = TileSet.new()
	main_ts.tile_size = Vector2i(64, 64)
	
	# Add physics layer
	main_ts.add_physics_layer()
	main_ts.set_physics_layer_collision_layer(0, 1)
	main_ts.set_physics_layer_collision_mask(0, 2)
	
	# Load main texture
	var main_tex = load("res://assets/island3/tiles/Tileset.png")
	if main_tex:
		var source = TileSetAtlasSource.new()
		source.texture = main_tex
		source.texture_region_size = Vector2i(64, 64)
		
		# Create tiles in a 10x10 grid (adjustable based on actual tileset size)
		for y in range(8):
			for x in range(12):
				var coord = Vector2i(x,y)
				source.create_tile(coord)
				
				# Give all solid ground tiles full collision by default
				# Exclude empty/decorative regions if known (e.g., y > 4)
				if y < 4:
					var polygon = PackedVector2Array([
						Vector2(-32, -32),
						Vector2(32, -32),
						Vector2(32, 32),
						Vector2(-32, 32)
					])
					source.tile_set_physics_polygon(coord, 0, polygon)
		
		main_ts.add_source(source, 0)
		
	ResourceSaver.save(main_ts, "res://resources/tilesets/island3_tileset.tres")
	print("Saved island3_tileset.tres")
	
	# 2. Decorations Tileset
	var dec_ts = TileSet.new()
	dec_ts.tile_size = Vector2i(64, 64)
	
	var dec_tex = load("res://assets/island3/tiles/Objects.png")
	if not dec_tex:
		dec_tex = load("res://assets/island3/tiles/Props.png")
		
	if dec_tex:
		var dec_source = TileSetAtlasSource.new()
		dec_source.texture = dec_tex
		dec_source.texture_region_size = Vector2i(64, 64)
		for y in range(6):
			for x in range(10):
				dec_source.create_tile(Vector2i(x,y))
		dec_ts.add_source(dec_source, 0)
		
	ResourceSaver.save(dec_ts, "res://resources/tilesets/island3_decorations.tres")
	print("Saved island3_decorations.tres")
	
	# Update LevelSelection.gd paths
	var ls_path = "res://scripts/levels/LevelSelection.gd"
	var file = FileAccess.open(ls_path, FileAccess.READ)
	if file:
		var content = file.get_as_text()
		file.close()
		
		# Make sure Island 3 paths are registered
		if not "\"Island 3\": [" in content:
			content = content.replace("}", ",\n\t\"Island 3\": [\n\t\t\"res://scenes/levels/Level_3_1.tscn\",\n\t\t\"res://scenes/levels/Level_3_2.tscn\",\n\t\t\"res://scenes/levels/Level_3_3.tscn\",\n\t\t\"res://scenes/levels/Level_3_4.tscn\",\n\t\t\"res://scenes/levels/Level_3_5.tscn\"\n\t]\n}")
			
			file = FileAccess.open(ls_path, FileAccess.WRITE)
			file.store_string(content)
			file.close()
			print("Updated LevelSelection.gd with Island 3 paths")
			
	print("Done!")
	quit()

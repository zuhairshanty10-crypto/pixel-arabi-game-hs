extends SceneTree

func _init():
	print("Running auto collision script...")
	
	# Load the tileset
	var ts_path = "res://resources/tilesets/island3_tileset.tres"
	var ts = load(ts_path) as TileSet
	if not ts:
		print("Could not load tileset.")
		quit(1)
		return
	
	var src = ts.get_source(0) as TileSetAtlasSource
	if not src:
		print("Atlas source 0 not found.")
		quit(1)
		return
	
	# Load Level_3_1.tscn
	var lvl = load("res://scenes/levels/Level_3_1.tscn").instantiate()
	var tm = lvl.get_node("TileMapLayer") as TileMapLayer
	if not tm:
		print("TileMapLayer not found.")
		quit(1)
		return
		
	var used_cells = tm.get_used_cells()
	var added_coords = []
	
	for cell in used_cells:
		var coords = tm.get_cell_atlas_coords(cell)
		if coords not in added_coords:
			added_coords.append(coords)
			var tile_data = src.get_tile_data(coords, 0)
			if tile_data:
				# Add physics layer polygon if empty
				var pcount = tile_data.get_collision_polygons_count(0)
				if pcount == 0:
					tile_data.add_collision_polygon(0)
					var poly = PackedVector2Array([Vector2(-8, -4), Vector2(8, -4), Vector2(8, 8), Vector2(-8, 8)])
					tile_data.set_collision_polygon_points(0, 0, poly)
					print("Added collision to tile: ", coords)
	
	ResourceSaver.save(ts, ts_path)
	print("Successfully saved updated TileSet!")
	quit()

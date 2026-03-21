extends SceneTree

func _init():
	print("Running pixel-perfect collision script...")
	
	var ts_path = "res://resources/tilesets/island3_tileset.tres"
	var ts = load(ts_path) as TileSet
	if not ts:
		print("Could not load tileset.")
		quit()
		return
	
	var src = ts.get_source(0) as TileSetAtlasSource
	if not src:
		print("Atlas source 0 not found.")
		quit()
		return
		
	var img = load("res://assets/island3/tiles/Medieval_tiles_free2.png").get_image()
	if not img:
		print("Failed to load image.")
		quit()
		return
	
	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(img, 0.1) # 10% opacity threshold
	
	# Load Level_3_1.tscn to know what tiles the user actually painted
	var lvl = load("res://scenes/levels/Level_3_1.tscn").instantiate()
	var tm = lvl.get_node("TileMapLayer") as TileMapLayer
	var used_cells = tm.get_used_cells()
	var processed_coords = []
	
	for cell in used_cells:
		var coords = tm.get_cell_atlas_coords(cell)
		if coords not in processed_coords:
			processed_coords.append(coords)
			var tile_data = src.get_tile_data(coords, 0)
			if tile_data:
				# Clear existing collision 
				var pcount = tile_data.get_collision_polygons_count(0)
				for i in range(pcount):
					tile_data.remove_collision_polygon(0, 0)
				
				# Get region in image
				var r = Rect2i(coords.x * 16, coords.y * 16, 16, 16)
				var polys = bitmap.opaque_to_polygons(r)
				
				if polys.size() > 0:
					for p in polys:
						# opaque_to_polygons returns vertices in local coordinates of the Rect2i!
						# The vertices go from (0,0) to (16,16).
						# We must convert them to Godot's tile local coordinates (-8, -8) to (8, 8).
						var local_poly = PackedVector2Array()
						for v in p:
							local_poly.append(v - Vector2(8, 8))
						
						# Simplify polygon slightly for physics performance
						# No built-in simplify for PackedVector2Array easily without Geometry2D, but we can just use the raw one
						
						var layer_index = 0
						tile_data.add_collision_polygon(0)
						tile_data.set_collision_polygon_points(0, tile_data.get_collision_polygons_count(0)-1, local_poly)
					print("Pixel-perfect collision added to ", coords)

	ResourceSaver.save(ts, ts_path)
	print("DONE! Resaved tileset.")
	quit()

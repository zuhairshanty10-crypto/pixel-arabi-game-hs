extends SceneTree

func _init():
	var ts = load("res://assets/island4/tileset/island4_tileset.tres")
	if ts:
		if ts.get_physics_layers_count() == 0:
			ts.add_physics_layer(0)
			
		ts.set_physics_layer_collision_layer(0, 1)
		ts.set_physics_layer_collision_mask(0, 1)
		
		var source = ts.get_source(0)
		if source is TileSetAtlasSource:
			for i in range(source.get_tiles_count()):
				var coords = source.get_tile_id(i)
				var td = source.get_tile_data(coords, 0)
				
				if td.get_collision_polygons_count(0) == 0:
					td.add_collision_polygon(0)
				
				td.set_collision_polygon_points(0, 0, PackedVector2Array([
					Vector2(-16, -16), Vector2(16, -16), 
					Vector2(16, 16), Vector2(-16, 16)
				]))
				
		ResourceSaver.save(ts, "res://assets/island4/tileset/island4_tileset.tres")
		print("FIXED COLLISIONS")
	else:
		print("FAILED TO LOAD TILESET")
	quit()

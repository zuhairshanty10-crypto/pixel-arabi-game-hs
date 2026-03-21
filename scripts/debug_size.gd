@tool
extends EditorScript

func _run() -> void:
	var tileset = TileSet.new()
	tileset.tile_size = Vector2i(32, 32)
	tileset.add_physics_layer(0)
	tileset.set_physics_layer_collision_layer(0, 1)
	tileset.set_physics_layer_collision_mask(0, 0)
	
	var source = TileSetAtlasSource.new()
	var tex = load("res://assets/island3/Tileset.png")
	source.texture = tex
	source.texture_region_size = Vector2i(32, 32)
	source.create_tile(Vector2i(0, 0))
	
	# In Godot 4, you MUST add the source to the tileset before modifying physics, 
	# BUT sometimes you have to get the tile_data AFTER it's fully added.
	tileset.add_source(source, 0)
	
	# Get the source back from the tileset to ensure it's linked
	var linked_source = tileset.get_source(0)
	var tile_data = linked_source.get_tile_data(Vector2i(0, 0), 0)
	
	tile_data.add_collision_polygon(0)
	tile_data.set_collision_polygon_points(0, 0, PackedVector2Array([
		Vector2(-16, -16), Vector2(16, -16), Vector2(16, 16), Vector2(-16, 16)
	]))
	
	print("Polys before save: ", tile_data.get_collision_polygons_count(0))
	ResourceSaver.save(tileset, "res://test_island3.tres")
	
	var loaded = load("res://test_island3.tres")
	var loaded_source = loaded.get_source(0)
	var loaded_data = loaded_source.get_tile_data(Vector2i(0, 0), 0)
	print("Polys after save: ", loaded_data.get_collision_polygons_count(0))

extends SceneTree
func _init():
	var img = Image.load_from_file('res://assets/island4/tileset/1 Tiles/Tileset.png')
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	ts.add_physics_layer(0)
	var source = TileSetAtlasSource.new()
	source.texture = ImageTexture.create_from_image(img)
	source.texture_region_size = Vector2i(32, 32)
	var cols = img.get_width() / 32
	var rows = img.get_height() / 32
	for y in range(rows):
		for x in range(cols):
			source.create_tile(Vector2i(x, y))
			# add basic collision
			source.tile_set_tile_data(Vector2i(x,y), 0).add_collision_polygon(0)
			source.tile_set_tile_data(Vector2i(x,y), 0).set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16,-16), Vector2(16,-16), Vector2(16,16), Vector2(-16,16)]))
	ts.add_source(source)
	ResourceSaver.save(ts, 'res://assets/island4/tileset/island4_tileset.tres')
	print('TILESET CREATED: SUCCESS')
	quit()


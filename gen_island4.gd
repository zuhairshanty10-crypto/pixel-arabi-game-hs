extends SceneTree

func _init():
	var img = Image.load_from_file('res://assets/island4/tileset/1 Tiles/Tileset.png')
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	ts.add_physics_layer(0)
	
	var source = TileSetAtlasSource.new()
	var itex = ImageTexture.create_from_image(img)
	source.texture = itex
	source.texture_region_size = Vector2i(32, 32)
	
	var cols = img.get_width() / 32
	var rows = img.get_height() / 32
	
	for y in range(rows):
		for x in range(cols):
			source.create_tile(Vector2i(x, y))
			var tdata = source.get_tile_data(Vector2i(x,y), 0)
			if tdata:
				tdata.add_collision_polygon(0)
				tdata.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16,-16), Vector2(16,-16), Vector2(16,16), Vector2(-16,16)]))
			
	ts.add_source(source)
	ResourceSaver.save(ts, 'res://assets/island4/tileset/island4_tileset.tres')
	print('TILESET CREATED: SUCCESS')
	
	var level = Node2D.new()
	level.name = 'Level_4_1'
	
	var pscene = load('res://scenes/player/Player.tscn')
	if pscene:
		var p = pscene.instantiate()
		p.position = Vector2(400, 200)
		level.add_child(p)
		p.owner = level
		
	var tml = TileMapLayer.new()
	tml.name = 'TileMapLayer'
	# Load the saved tileset to ensure it references the external resource properly
	tml.tile_set = load('res://assets/island4/tileset/island4_tileset.tres')
	level.add_child(tml)
	tml.owner = level
	
	var packed = PackedScene.new()
	packed.pack(level)
	ResourceSaver.save(packed, 'res://scenes/levels/Level_4_1.tscn')
	print('LEVEL CREATED: SUCCESS')
	
	quit()

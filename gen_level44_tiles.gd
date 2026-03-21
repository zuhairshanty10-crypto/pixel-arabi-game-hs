extends SceneTree

func _init():
	var scene = load('res://scenes/levels/Level_4_4.tscn')
	var level = scene.instantiate()
	var tilemap = level.get_node('TileMapLayer')
	var ts = tilemap.tile_set
	var src_id = ts.get_source_id(0)
	
	# Section 1: Starting platform (x=0 to x=24)
	for x in range(0, 25):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 2: Spike gap (x=25-33 open, with only falling platforms)
	# Safe landing after gap
	for x in range(34, 38):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 3: Fire + Saw corridor (x=38 to x=55)
	for x in range(38, 56):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Gap before vertical section
	# Section 4: Climbing platforms
	for x in range(57, 61):
		tilemap.set_cell(Vector2i(x, 27), src_id, Vector2i(0, 0))
	for x in range(62, 66):
		tilemap.set_cell(Vector2i(x, 24), src_id, Vector2i(0, 0))
	for x in range(67, 73):
		tilemap.set_cell(Vector2i(x, 21), src_id, Vector2i(0, 0))
	# Drop down
	for x in range(73, 77):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 5: Troll area (x=77 to x=86)
	for x in range(77, 87):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 6: MASSIVE arena (x=88 to x=115)
	for x in range(88, 116):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Arena walls
	for y in range(23, 29):
		tilemap.set_cell(Vector2i(88, y), src_id, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(115, y), src_id, Vector2i(0, 0))
	
	# Small elevated platforms inside arena for vertical combat
	for x in range(95, 99):
		tilemap.set_cell(Vector2i(x, 25), src_id, Vector2i(0, 0))
	for x in range(105, 109):
		tilemap.set_cell(Vector2i(x, 25), src_id, Vector2i(0, 0))
	
	var packed = PackedScene.new()
	packed.pack(level)
	ResourceSaver.save(packed, 'res://scenes/levels/Level_4_4.tscn')
	print('LEVEL 4-4 TILES DONE')
	quit()

extends SceneTree

func _init():
	var scene = load('res://scenes/levels/Level_4_5.tscn')
	var level = scene.instantiate()
	var tilemap = level.get_node('TileMapLayer')
	var ts = tilemap.tile_set
	var src_id = ts.get_source_id(0)
	
	# Flat arena floor (x=0 to x=60)
	for x in range(0, 61):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Solid walls to prevent falling out
	for y in range(20, 30):
		tilemap.set_cell(Vector2i(-1, y), src_id, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(61, y), src_id, Vector2i(0, 0))
	
	var packed = PackedScene.new()
	packed.pack(level)
	ResourceSaver.save(packed, 'res://scenes/levels/Level_4_5.tscn')
	print('LEVEL 4-5 TILES GENERATED')
	quit()

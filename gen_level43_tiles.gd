extends SceneTree

func _init():
	# Load the Level 4-3 scene
	var scene = load('res://scenes/levels/Level_4_3.tscn')
	var level = scene.instantiate()
	var tilemap = level.get_node('TileMapLayer')
	
	if not tilemap:
		print('ERROR: No TileMapLayer')
		quit()
		return
	
	var ts = tilemap.tile_set
	if not ts or ts.get_source_count() == 0:
		print('ERROR: No tileset sources')
		quit()
		return
	
	var src_id = ts.get_source_id(0)
	
	# Section 1: Starting platform (x=0 to x=24, y=29) - long flat ground
	for x in range(0, 25):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 2: Spike pit gap (x=25 to x=28 is empty for spikes)
	# Small platform before gap
	for x in range(25, 27):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Platform after spike pit (x=30 to x=33)
	for x in range(30, 34):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 3: Fire corridor (x=34 to x=48)
	for x in range(34, 49):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 4: Elevated platforms - stairs going up
	# Step 1
	for x in range(50, 54):
		tilemap.set_cell(Vector2i(x, 27), src_id, Vector2i(0, 0))
	# Step 2
	for x in range(55, 59):
		tilemap.set_cell(Vector2i(x, 25), src_id, Vector2i(0, 0))
	# Step 3 - hellhound platform
	for x in range(60, 68):
		tilemap.set_cell(Vector2i(x, 23), src_id, Vector2i(0, 0))
	
	# Drop down back to ground
	for x in range(68, 72):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Section 5: Saw gauntlet (narrow platforms)
	for x in range(73, 76):
		tilemap.set_cell(Vector2i(x, 27), src_id, Vector2i(0, 0))
	for x in range(77, 80):
		tilemap.set_cell(Vector2i(x, 25), src_id, Vector2i(0, 0))
	for x in range(81, 84):
		tilemap.set_cell(Vector2i(x, 27), src_id, Vector2i(0, 0))
	
	# Section 6: Final arena - big flat platform
	for x in range(85, 105):
		tilemap.set_cell(Vector2i(x, 29), src_id, Vector2i(0, 0))
	
	# Walls on sides of arena
	for y in range(25, 29):
		tilemap.set_cell(Vector2i(85, y), src_id, Vector2i(0, 0))
		tilemap.set_cell(Vector2i(104, y), src_id, Vector2i(0, 0))
	
	# Save the scene
	var packed = PackedScene.new()
	packed.pack(level)
	ResourceSaver.save(packed, 'res://scenes/levels/Level_4_3.tscn')
	print('LEVEL 4-3 TILES GENERATED')
	quit()

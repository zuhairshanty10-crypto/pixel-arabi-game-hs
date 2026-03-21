@tool
extends SceneTree

func _init():
	print("Starting super generator v2...")
	var f = FileAccess.open("tileset_inventory.json", FileAccess.READ)
	if not f:
		print("Inventory not found")
		quit()
	var inventory = JSON.parse_string(f.get_as_text())
	
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 2)
	
	var img_tileset = Image.load_from_file("res://assets/island1/Tileset.png")
	var img_objects = Image.load_from_file("res://assets/island1/Objects.png")
	var img_details = Image.load_from_file("res://assets/island1/Details.png")
	
	# Godot 3 exported maps to Godot 4 via Source 0.
	# It maps atlas coords: Vector2i(id % atlas_cols, id / atlas_cols).
	# Wait, looking at Level 01:
	# Ground is Atlas:(0, 11) using Source 0.
	# Let's look at Tileset.png. It is 14x14 tiles (448x448). So max index is 195.
	# But in Level 01, Ground is at (0, 11). Wait, (0, 11) on a 14-col grid is ID 154.
	# Let's check Tileset.png visually. The ground is on the 12th row (index 11), column 0?
	# YES, the first tile of row 12 is often the top-left dirt tile!
	# So Godot 4 *did* map the ID correctly to its (x,y) on the texture!
	
	# Now what about `Deco (-78, 91) -> Src:0 Atlas:(12, 9) Alt:0` (HiddenSpike?).
	# In `Objects.png`, spikes might be at some position.
	# But Godot 4 is asking for Source 0, Atlas: (12, 9).
	# Does `Tileset.png` have something at (12, 9)? No, it's 14x14. It DOES have a (12, 9)!
	# But if it's looking for an object, and Objects.png is 40x10.
	# If the original ID was from Objects.png, say ID 65 -> Source 0, Atlas (65%14, 65/14) = (9, 4)?
	# Wait, if `Tileset.png` is assigned as Source 0, and the Decor layer expects things like `(12, 9)`, maybe Godot 3 merged them into one TileSet but assigned them different IDs?
	# In Godot 4, it uses Source 0 and just literal coordinates on that Source's texture.
	# Since it only uses Source 0, we can't just give it the small Tileset.png. We MUST provide a texture that has EVERYTHING it asks for at the EXACT coordinates it asks for.
	
	# How do we know what goes at (12, 9)?
	# We'd have to look at the Tiled map or guess!
	# But wait! User originally said `Source ID 55` is invalid.
	# That means `island1_tileset.tres` was supposed to have Source IDs 55, 56, etc.!
	# BUT `Level_01.tscn` uses Source 0 for EVERYTHING?
	# No, wait... my output said `Found TileMapLayer! Cell -> Src: 0... Filtered sample of 10 cells`
	# Ah! All the first 10 cells of TileMapLayer are the solid block floor, which is Source 0.
	# ALL the first 10 cells of Decorations were ID 0, because maybe they were something from Tileset.png!
	print("Checking ALL cells for Source IDs other than 0")
	var scene = ResourceLoader.load("res://scenes/levels/Level_01.tscn")
	var instance = scene.instantiate()
	var layer = instance.get_node("TileMapLayer")
	
	var all_sources = {}
	if layer:
		for pos in layer.get_used_cells():
			var src = layer.get_cell_source_id(pos)
			all_sources[src] = true
	var layer2 = instance.get_node("Decorations")
	if layer2:
		for pos in layer2.get_used_cells():
			var src = layer2.get_cell_source_id(pos)
			all_sources[src] = true
			
	print("ALL SOURCES USED IN LEVEL 01 BY GODOT:")
	print(all_sources.keys())
	quit()

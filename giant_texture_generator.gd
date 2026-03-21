@tool
extends SceneTree

func _init():
	print("Building Godot 3 to 4 Combined TileSet Atlas Mapper...")
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 2)
	
	# The Godot 3 TileSet exporter for Tiled did something very specific.
	# Tileset.png was GID 106.
	# Objects.png was GID 2686.
	# Wait, in the inventory we saw: `"55":{"layers":{"Decorations":true,"TileMapLayer":true},"tiles":{"(0,0)/11":true...`
	# These IDs (55) are Godot 3 Tile IDs, not Tiled GIDs!
	# In Godot 3, each texture gets ONE Tile ID if it's an atlas, or multiple if it's single tiles!
	# The inventory shows single Tile IDs!
	# "55", "56", ..., "94". 
	# Wait! If Godot 3 assigned them as single tiles instead of an atlas, the ID in Godot 3 is just an integer.
	# When Godot 4 upgrades this, it maps them all to Source 0.
	# Godot 4 maps old ID `id` to atlas_coords = `Vector2i(id % cols, id / cols)` where `cols` is the width in tiles of the FIRST texture in the old TileSet.
	# What was the first texture?
	# We deduced that ID 154 mapped to `(0, 11)`. 154 / 11 = 14! 
	# Which means the Godot 3 TileSet's "first texture" was 14 tiles wide.
	# `Tileset.png` is 448x384. 448 / 32 = 14 columns!
	
	# So Godot 4 thinks EVERY Godot 3 Tile ID is mapped to a grid of 14 columns.
	# `(16, 0)` -> ID = 16.
	# `(16, 1)` -> ID = 16 + 14 = 30.
	# `(16, 4)` -> ID = 16 + 56 = 72.
	# `(36, 4)` -> ID = 36 + 56 = 92.
	# `(9, 5)` -> ID = 9 + 70 = 79.
	# `(21, 5)` -> ID = 21 + 70 = 91.
	# `(12, 9)` -> ID = 12 + 126 = 138.
	
	# Wait, does the inventory match this math?
	# Inventory "tiles":
	# "72": {"tiles": {"(0,0)/11": true, "(0,28)/2": true}}
	# "92": {"tiles": {"(0,10)/3": true ...}}
	# EXACT MATCH!!
	# The inventory keys (55, 72, 92) ARE the Godot 3 IDs!
	# And the level uses `(16, 4)` which is ID 72!
	
	# So, to fix this perfectly:
	# 1. We create a giant texture for Source 0.
	# 2. For every Godot 3 ID in the inventory:
	# 3. We calculate its Godot 4 Atlas Coord: `ax = id % 14`, `ay = id / 14`.
	# 4. We look at the inventory to see WHICH image and Sub-Atlas coord it REALLY corresponds to!
	#	Inventory says: ID 72 corresponds to `(0,28)/2` in the old setup context... 
	#	Wait, the inventory generator `manual_decode.gd` said:
	#	`Texture: res://assets/island3/Details.png` (or Objects.png).
	#	Ah! The inventory `tileset_inventory.json` from the backup already stripped the image info?
	#	Let's check `super_generator.gd` heuristics:
	#	`elif sid >= 80: source.texture = tex_objects; else: source.texture = tex_details`
	#	Wait, ID 0 was `tex_tileset`. ID 1 to 79 was `tex_details`. ID 80+ was `tex_objects`.
	
	var img_tileset = Image.load_from_file("res://assets/island1/Tileset.png")
	var img_objects = Image.load_from_file("res://assets/island1/Objects.png")
	var img_details = Image.load_from_file("res://assets/island1/Details.png")
	
	# We need to build a single giant Image that acts as the Source 0 texture.
	# What dimensions? The max atlas coords used is (36, 11).
	# Let's make it 40 columns and 15 rows. (1280 x 480).
	var giant_img = Image.create_empty(1280, 480, false, Image.FORMAT_RGBA8)
	
	# Copy Tileset.png directly into the top-left! It was the base.
	var src_rect = Rect2i(0, 0, img_tileset.get_width(), img_tileset.get_height())
	giant_img.blit_rect(img_tileset, src_rect, Vector2i(0, 0))
	
	# Load the inventory to map the rest
	var f = FileAccess.open("tileset_inventory.json", FileAccess.READ)
	var inventory = JSON.parse_string(f.get_as_text())
	
	# What we need to do is simple:
	# Godot 3 had IDs from 1 to ~150.
	# The level `Level_01.tscn` expects to find the tile for ID X at `(X % 14, X / 14)`.
	# So we just need to put the correct 32x32 image block at `(X % 14, X / 14)` on `giant_img`.
	# But WHICH image block was ID X in Godot 3?
	# In `super_generator.gd`, I assumed:
	# 0 = Tileset.png (Actually, it was the whole Tileset.png file!)
	# Wait, if `Tileset.png` is the first 196 IDs, then ID 0 to 195 are just Tileset.png.
	# If ID 196+ are Details.png?
	# Where are objects?
	
	# Let's look at `tileset_inventory.json`:
	# The user says "Source 55 is invalid".
	# The inventory has "55" through "94".
	# These are the Godot 3 IDs!
	# But they are 55 to 94.
	# Wait, `Tileset.png` is 196 tiles. How can 55 be an object if Tileset is 196 tiles long?!
	# In Godot 3, you add a texture and ASSIGN an ID manually. 
	# Maybe the developer manually assigned ID 0 to Tileset.png, ID 55 to a specific object rock, ID 56 to a spike...
	# And since ID 55 was a Single Tile in Godot 3, what texture did it use?
	# Let's find ANY Godot 3 resource or Tiled map to know exactly what ID 55 is.
	
	# Actually, I can just use my `decode_island3.gd` output from before:
	# The user provided `tileset_inventory.json`, which has:
	# `55`: layers: {Decorations: true}, tiles: {"(0,0)/11": true}
	# Wait, the string `"(0,0)/11"` was parsed from Godot 4 `island3_tileset.tres`!
	# In `island3`, Source ID 55 corresponds to an Image.
	# Which image? I can parse `island3_tileset.tres` to see what texture Source ID 55 uses!
	
	var ts3 = load("res://resources/tilesets/island3_decorations_tileset.tres")
	if ts3 == null:
		print("Island 3 tileset not found?")
		
	var mapping = {}
	for sid_str in inventory.keys():
		var sid = sid_str.to_int()
		if sid == 0: continue
		
		if ts3 and ts3.has_source(sid):
			var src3 = ts3.get_source(sid)
			if src3 is TileSetAtlasSource:
				var tex = src3.texture
				var region = src3.get_tile_texture_region(Vector2i(0,0), 0)
				mapping[sid] = {"texture": tex, "region": region}
	
	for sid in mapping.keys():
		var target_ax = sid % 14
		var target_ay = sid / 14
		var dest_pos = Vector2i(target_ax * 32, target_ay * 32)
		
		var tex = mapping[sid]["texture"]
		if tex is Texture2D:
			var img = tex.get_image()
			giant_img.blit_rect(img, mapping[sid]["region"], dest_pos)
			
	giant_img.save_png("res://assets/island1/Composite_Tileset.png")
	print("Composite Image Saved!")
	
	var final_ts = TileSet.new()
	final_ts.tile_size = Vector2i(32, 32)
	final_ts.add_physics_layer()
	final_ts.set_physics_layer_collision_layer(0, 1)
	final_ts.set_physics_layer_collision_mask(0, 2)
	
	var final_tex = ImageTexture.create_from_image(giant_img)
	var final_src = TileSetAtlasSource.new()
	final_src.texture = final_tex
	final_src.texture_region_size = Vector2i(32, 32)
	final_ts.add_source(final_src, 0)
	
	for y in range(480 / 32):
		for x in range(1280 / 32):
			final_src.create_tile(Vector2i(x, y))
			if y <= 11 and x <= 13: # Tileset area roughly
				var td = final_src.get_tile_data(Vector2i(x,y), 0)
				if td:
					td.add_collision_polygon(0)
					td.set_collision_polygon_points(0, 0, PackedVector2Array([Vector2(-16,-16), Vector2(16,-16), Vector2(16,16), Vector2(-16,16)]))
	
	ResourceSaver.save(final_ts, "res://resources/tilesets/island1_tileset.tres")
	print("FINAL TILESET SAVED!")
	quit()

@tool
extends SceneTree

func _init():
	print("Starting Godot 3 to 4 Combined TileSet Atlas Mapper...")
	var ts = TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	ts.add_physics_layer()
	ts.set_physics_layer_collision_layer(0, 1)
	ts.set_physics_layer_collision_mask(0, 2)
	
	var img_tileset = Image.load_from_file("res://assets/island1/Tileset.png")
	var tex_tileset = ImageTexture.create_from_image(img_tileset)
	
	var img_objects = Image.load_from_file("res://assets/island1/Objects.png")
	var tex_objects = ImageTexture.create_from_image(img_objects)
	
	var img_details = Image.load_from_file("res://assets/island1/Details.png")
	var tex_details = ImageTexture.create_from_image(img_details)
	
	var max_cols = 40 # Based on Objects.png being 1280 wide (1280/32=40)
	var max_rows = 12 # Based on Level 01 needing up to (X, 11)
	
	# Wait, if `Tileset.png` is assigned as Source 0 in Godot 4, 
	# and the level expects to find things at (16,0) representing Objects...
	# That means Godot 3 exported a single TileSet containing multiple textures!
	# In Godot 3, each texture added to a TileSet was assigned an ID, e.g. Tileset=0, Objects=196, Details=xxx
	# When Godot 4 upgrades this, it places ALL Godot 3 IDs into a SINGLE TileSetAtlasSource (Source 0),
	# mapping Godot 3 ID -> Godot 4 Atlas Coords via `Vector2i(id % cols, id / cols)`.
	# BUT WHICH `cols`?
	# Godot 4 upgrade script uses the FIRST texture's width to determine `cols`.
	# `Tileset.png` is 448 pixels wide -> 448 / 32 = 14 columns.
	# So ID 154 (Ground) -> (154 % 14, 154 / 14) -> (0, 11)! Exactly correct!
	
	# Wait, if `cols` is 14, let's test coordinate `(16, 0)`.
	# (16, 0) -> ID = 16 + (0 * 14) = 16. But wait, `16 % 14` is 2, not 16!
	# Ah, `atlas_coords.x` can be greater than `cols` if Godot allowed it?
	# No, Godot 4 allows atlas_coords.x up to the image width.
	# If `(16,0)` is requested, it implies a texture width of AT LEAST 17 columns (17*32 = 544).
	# Is `Tileset.png` 14 columns? Wait!
	# The user's tileset_inventory.json output showed max `(0,39)`? No, it was `(0, 11)/x`.
	
	# Let's inspect the `Tileset.png` file size.
	print("Tileset.png size: ", img_tileset.get_width(), "x", img_tileset.get_height())
	print("Objects.png size: ", img_objects.get_width(), "x", img_objects.get_height())
	print("Details.png size: ", img_details.get_width(), "x", img_details.get_height())
	
	# What if we just merge all 3 images into ONE GIANT texture?
	# And then map the requested coordinates onto it?
	# If the level asks for (16, 4), and we put the exact right 32x32 block at (16, 4) in our giant texture, it will render!
	# But which block belongs at (16, 4)?
	# We know Godot 3 IDs. But we don't know the exact mapping of Godot 3 IDs to the 3 textures unless we look at the Tiled map?
	# The user used Tiled. In Tiled, "First GID" defines the ID ranges.
	# Let's look at `Map.tmx` to find the First GIDs!
	var f = FileAccess.open("res://island3/TILED_files/Map.tmx", FileAccess.READ)
	if f:
		var txt = f.get_as_text()
		var regex = RegEx.new()
		regex.compile("<tileset firstgid=\"(\\d+)\" name=\"([^\"]+)\"")
		for match in regex.search_all(txt):
			print("TILESET: ", match.get_string(2), " FIRST GID: ", match.get_string(1))
	quit()

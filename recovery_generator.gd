@tool
extends SceneTree

func _init():
    var f = FileAccess.open("simple_inventory.json", FileAccess.READ)
    if not f:
        print("Inventory not found")
        quit()
    var all_tiles = JSON.parse_string(f.get_as_text())
    
    # 1. Determine max dimensions
    var max_ax = 16 # Default for 544 wide
    var max_ay = 11 # Default for 384 high
    for sid in all_tiles.keys():
        for tile_key in all_tiles[sid].keys():
            var coords_str = tile_key.split("/")[0]
            var parts = coords_str.split(",")
            max_ax = max(max_ax, parts[0].to_int())
            max_ay = max(max_ay, parts[1].to_int())
    
    print("Max Coords needed: (%d, %d)" % [max_ax, max_ay])
    
    # 2. Create the Tall Image
    var base_img = Image.load_from_file("res://assets/island1/Tileset.png")
    var tall_img = Image.create((max_ax + 1) * 32, (max_ay + 1) * 32, false, base_img.get_format())
    
    var base_rows = base_img.get_height() / 32
    var base_cols = base_img.get_width() / 32
    
    for y in range(max_ay + 1):
        var src_y = y % base_rows
        for x in range(max_ax + 1):
            var src_x = x % base_cols
            var rect = Rect2i(src_x * 32, src_y * 32, 32, 32)
            tall_img.blit_rect(base_img, rect, Vector2i(x * 32, y * 32))
            
    tall_img.save_png("res://assets/island1/TallTileset.png")
    print("Tall texture saved")
    
    # 3. Create the TileSet
    var ts = TileSet.new()
    ts.tile_size = Vector2i(32, 32)
    ts.add_physics_layer()
    ts.set_physics_layer_collision_layer(0, 1)
    ts.set_physics_layer_collision_mask(0, 2)
    
    var tex = load("res://assets/island1/TallTileset.png")
    var poly = PackedVector2Array([Vector2(-16,-16), Vector2(16,-16), Vector2(16,16), Vector2(-16,16)])
    
    for sid_str in all_tiles.keys():
        var sid = sid_str.to_int()
        var source = TileSetAtlasSource.new()
        source.texture = tex
        source.texture_region_size = Vector2i(32, 32)
        ts.add_source(source, sid)
        
        for tile_key in all_tiles[sid_str].keys():
            var main_parts = tile_key.split("/")
            var coords_str = main_parts[0]
            var alt = main_parts[1].to_int()
            var parts = coords_str.split(",")
            var ax = parts[0].to_int()
            var ay = parts[1].to_int()
            var coords = Vector2i(ax, ay)
            
            if not source.has_tile(coords):
                source.create_tile(coords)
                # Add physics to ALL tiles for now to be safe
                var td = source.get_tile_data(coords, 0)
                if td:
                    td.add_collision_polygon(0)
                    td.set_collision_polygon_points(0, 0, poly)
            
            if alt != 0:
                if not source.has_alternative_tile(coords, alt):
                    source.create_alternative_tile(coords, alt)
                    
    ResourceSaver.save(ts, "res://resources/tilesets/island1_tileset.tres")
    print("ALL DONE! island1_tileset.tres is now compatible.")
    quit()

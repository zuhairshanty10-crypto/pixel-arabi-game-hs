@tool
extends SceneTree

func _init():
    var f = FileAccess.open("simple_inventory.json", FileAccess.READ)
    if not f: quit()
    var all_tiles = JSON.parse_string(f.get_as_text())
    
    var max_ax = 16 
    var max_ay = 36 
    
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
    var tex = ImageTexture.create_from_image(tall_img)
    
    var ts = TileSet.new()
    ts.tile_size = Vector2i(32, 32)
    ts.add_physics_layer() # Adds layer 0
    
    var poly = PackedVector2Array([Vector2(-16,-16), Vector2(16,-16), Vector2(16,16), Vector2(-16,16)])
    
    for sid_str in all_tiles.keys():
        var sid = sid_str.to_int()
        var source = TileSetAtlasSource.new()
        source.texture = tex
        source.texture_region_size = Vector2i(32, 32)
        
        # ADD SOURCE FIRST!
        ts.add_source(source, sid)
        
        var tiles = all_tiles[sid_str].keys()
        tiles.sort() # Ensure we process alt 0 entries first
        
        for tile_key in tiles:
            var parts = tile_key.split("/")
            var coords = Vector2i(parts[0].split(",")[0].to_int(), parts[0].split(",")[1].to_int())
            var alt = parts[1].to_int()
            
            if not source.has_tile(coords):
                source.create_tile(coords)
                # Map to physical collision
                var td = source.get_tile_data(coords, 0)
                if td:
                    td.add_collision_polygon(0)
                    td.set_collision_polygon_points(0, 0, poly)
            
            if alt != 0:
                if not source.has_alternative_tile(coords, alt):
                    source.create_alternative_tile(coords, alt)
                    
    ResourceSaver.save(ts, "res://resources/tilesets/island1_tileset.tres")
    print("ULTIMATE COMPATIBILITY SAVED WITH PHYSICS!")
    quit()

@tool
extends SceneTree

func _init():
    var f = FileAccess.open("tileset_inventory.json", FileAccess.READ)
    if not f:
        print("Inventory not found")
        quit()
    var inventory = JSON.parse_string(f.get_as_text())
    
        # Godot levels have assigned almost everything to Source 0 somehow!
        # If the level asks for Src:0 Atlas:(16,4), it's looking for a decoration tile in Source 0?
        # NO! In Godot 3 to 4 migration, TileMap tile IDs are converted to: atlas_coords = Vector2i(id % cols, id / cols), and source_id = 0!
        # This means all tiles from the old Godot 3 TileSet became Source 0, but with varied Atlas Coordinates based on their old Godot 3 ID!
        
        # If old ID was 55, Godot 4 expects Source 0, Atlas: (55, 0) if cols = 1, or something similar.
        # But wait, looking at `Cell (-90, 84) -> Src:0 Atlas:(0, 11) Alt:0`.
        # (0, 11)... Is that 11th tile?
        pass
                
            if not source.has_tile(atlas_coords):
                if ax < tex_cols and ay < tex_rows:
                    source.create_tile(atlas_coords)
                    # Add physics ONLY for floor-like layers or Source 0
                    if sid == 0 or info["layers"].has("TileMapLayer"):
                        var td = source.get_tile_data(atlas_coords, 0)
                        if td:
                            td.add_collision_polygon(0)
                            td.set_collision_polygon_points(0, 0, poly)
            
            # Add alternative
            if alt != 0:
                if ax < tex_cols and ay < tex_rows:
                    if not source.has_alternative_tile(atlas_coords, alt):
                        source.create_alternative_tile(atlas_coords, alt)
                    
    ResourceSaver.save(ts, "res://resources/tilesets/island1_tileset.tres")
    print("SUPER COMPATIBILITY TILESET SAVED!")
    quit()

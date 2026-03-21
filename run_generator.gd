extends SceneTree

func _init() -> void:
    print("Force running TileSet generator with debugging...")
    var script = load("res://scripts/CreateIsland3TileSet.gd").new()
    script._run()
    
    # Reload and check
    var loaded = load("res://resources/tilesets/island3_tileset.tres")
    var source = loaded.get_source(0)
    print("Tile at (5,0) (should be empty): polys = ", source.get_tile_data(Vector2i(5, 0), 0).get_collision_polygons_count(0))
    print("Tile at (0,0) (should be solid): polys = ", source.get_tile_data(Vector2i(0, 0), 0).get_collision_polygons_count(0))
    
    print("Done generating.")
    quit()

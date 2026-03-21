@tool
extends SceneTree

func _init():
    var ts = load("res://resources/tilesets/island3_decorations_tileset.tres")
    if not ts:
        print("Failed to load island3_decorations_tileset.tres")
        quit()
    
    for i in range(ts.get_source_count()):
        var sid = ts.get_source_id(i)
        var source = ts.get_source(sid)
        if source is TileSetAtlasSource:
            var tex = source.texture
            if tex:
                print("Source %d: %s" % [sid, tex.resource_path])
    quit()

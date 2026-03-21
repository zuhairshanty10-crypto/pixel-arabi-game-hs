@tool
extends SceneTree

func _init():
    var ts = load("res://resources/tilesets/forest_tileset.tres")
    if not ts:
        print("Failed to load forest_tileset.tres")
        quit()
    
    for i in range(ts.get_source_count()):
        var sid = ts.get_source_id(i)
        var source = ts.get_source(sid)
        if source is TileSetAtlasSource:
            var tex = source.texture
            if tex:
                print("Source %d: %s" % [sid, tex.resource_path])
            else:
                print("Source %d: NO TEXTURE" % sid)
    quit()

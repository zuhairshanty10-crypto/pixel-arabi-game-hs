@tool
extends SceneTree

func _init():
    var levels = ["Level_01.tscn", "Level_02.tscn", "Level_03.tscn", "Level_04.tscn", "Level_05.tscn"]
    var source_info = {} # sid -> layer_name -> tiles_set

    for level_name in levels:
        var path = "res://scenes/levels/" + level_name
        var file = FileAccess.open(path, FileAccess.READ)
        if not file: continue
        var content = file.get_as_text()
        
        # Find all TileMapLayer nodes and their data
        var layer_regex = RegEx.new()
        layer_regex.compile("\\[node name=\"(?<name>[^\"]+)\" type=\"TileMapLayer\"[^\\]]*\\](?:\\r?\\n)+[^k]*tile_map_data = PackedByteArray\\(\"(?<data>[^\"]+)\"\\)")
        
        var matches = layer_regex.search_all(content)
        for m in matches:
            var layer_name = m.get_string("name")
            var b64_data = m.get_string("data")
            var data = Marshalls.base64_to_raw(b64_data)
            
            for i in range(0, data.size(), 12):
                if i + 11 >= data.size(): break
                var sid = data.decode_s16(i + 4)
                var ax = data.decode_s16(i + 6)
                var ay = data.decode_s16(i + 8)
                var alt = data.decode_s16(i + 10)
                
                if not source_info.has(sid):
                    source_info[sid] = {"layers": {}, "tiles": {}}
                source_info[sid]["layers"][layer_name] = true
                var tile_key = "(%d,%d)/%d" % [ax, ay, alt]
                source_info[sid]["tiles"][tile_key] = true
    
    # Save the inventory to a temporary file
    var out_file = FileAccess.open("tileset_inventory.json", FileAccess.WRITE)
    out_file.store_string(JSON.stringify(source_info))
    print("INVENTORY SAVED for %d sources" % source_info.size())
    quit()

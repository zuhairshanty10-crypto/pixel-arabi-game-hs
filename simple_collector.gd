@tool
extends SceneTree

func _init():
    var levels = ["Level_01.tscn", "Level_02.tscn", "Level_03.tscn", "Level_04.tscn", "Level_05.tscn"]
    var all_tiles = {} # sid -> "ax,ay/alt" -> true

    for level_name in levels:
        var path = "res://scenes/levels/" + level_name
        var file = FileAccess.open(path, FileAccess.READ)
        if not file: continue
        var content = file.get_as_text()
        
        var regex = RegEx.new()
        regex.compile("PackedByteArray\\(\"([^\"]+)\"\\)")
        var matches = regex.search_all(content)
        for m in matches:
            var data = Marshalls.base64_to_raw(m.get_string(1))
            for i in range(0, data.size(), 12):
                if i + 11 >= data.size(): break
                var sid = data.decode_s16(i+4)
                var ax = data.decode_s16(i+6)
                var ay = data.decode_s16(i+8)
                var alt = data.decode_s16(i+10)
                
                if not all_tiles.has(sid): all_tiles[sid] = {}
                var key = "%d,%d/%d" % [ax, ay, alt]
                all_tiles[sid][key] = true
                
    var out = FileAccess.open("simple_inventory.json", FileAccess.WRITE)
    out.store_string(JSON.stringify(all_tiles))
    print("SIMPLE INVENTORY SAVED: %d sources" % all_tiles.size())
    quit()

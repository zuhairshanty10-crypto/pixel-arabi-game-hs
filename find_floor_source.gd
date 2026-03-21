@tool
extends SceneTree

func _init():
    var file = FileAccess.open("res://scenes/levels/Level_01.tscn", FileAccess.READ)
    if not file: quit()
    var content = file.get_as_text()
    var regex = RegEx.new()
    regex.compile("PackedByteArray\\(\"([^\"]+)\"\\)")
    var matches = regex.search_all(content)
    
    for m in matches:
        var b64 = m.get_string(1)
        var data = Marshalls.base64_to_raw(b64)
        print("\nFloor detection:")
        for i in range(0, data.size(), 12):
            if i + 11 >= data.size(): break
            var x = data.decode_s16(i)
            var y = data.decode_s16(i + 2)
            var sid = data.decode_s16(i + 4)
            if x > 5 and x < 50: # Check a horizontal range
                print("  Tile at (%d, %d): source=%d" % [x, y, sid])
    quit()

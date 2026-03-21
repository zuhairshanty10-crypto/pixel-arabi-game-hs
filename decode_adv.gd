@tool
extends SceneTree

func _init():
    var file = FileAccess.open("res://scenes/levels/Level_2_1.tscn", FileAccess.READ)
    if not file: quit()
    var content = file.get_as_text()
    var regex = RegEx.new()
    regex.compile("PackedByteArray\\(\"([^\"]+)\"\\)")
    var matches = regex.search_all(content)
    
    for m in matches:
        var b64 = m.get_string(1)
        var data = Marshalls.base64_to_raw(b64)
        print("\nDecoding Segment:")
        for i in range(0, min(data.size(), 48), 12):
            var bytes = []
            for j in range(12): bytes.append(data[i+j])
            print("Raw: %s" % str(bytes))
            # Test different pairings
            print("  Pair 0-1 (x?): %d" % data.decode_s16(i))
            print("  Pair 2-3 (y?): %d" % data.decode_s16(i+2))
            print("  Pair 4-5 (source?): %d" % data.decode_s16(i+4))
            print("  Pair 6-7 (ax?): %d" % data.decode_s16(i+6))
            print("  Pair 8-9 (ay?): %d" % data.decode_s16(i+8))
            print("  Pair 10-11 (alt?): %d" % data.decode_s16(i+10))
            
    quit()

@tool
extends SceneTree

func _init():
    var b64 = "AACm/1QAAAAAAAsAAACn/1QAAAAAAAsAAACo/1QAAAAAAAsAAACp/1QAAAAAAAsAAACq/1QAAAAAAAsAAACr/1QAAAAAAAsAAACs/1QAAAAAAAsA"
    var data = Marshalls.base64_to_raw(b64)
    print("Decoding Manual Segment:")
    for i in range(0, data.size(), 12):
        if i + 11 >= data.size(): break
        var x = data.decode_s16(i)
        var y = data.decode_s16(i+2)
        var sid = data.decode_s16(i+4)
        var ax = data.decode_s16(i+6)
        var ay = data.decode_s16(i+8)
        var alt = data.decode_s16(i+10)
        print("Tile: sid=%d, atlas=(%d,%d), alt=%d" % [sid, ax, ay, alt])
    quit()

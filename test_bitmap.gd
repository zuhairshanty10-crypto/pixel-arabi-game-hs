@tool
extends EditorScript

func _run() -> void:
    var tex = load("res://assets/island3/Tileset.png")
    var img = tex.get_image()
    var bitmap = BitMap.new()
    bitmap.create_from_image_alpha(img, 0.5)
    
    # Test on a known non-empty tile at (x=0, y=0) or (x=5, y=5)
    var rect = Rect2i(0, 0, 32, 32)
    var polys = bitmap.opaque_to_polygons(rect, 1.0)
    
    print("Found ", polys.size(), " polygons for rect ", rect)
    if polys.size() > 0:
        print("First poly points: ", polys[0])
        # Convert to local center
        var local_points = PackedVector2Array()
        for pt in polys[0]:
            local_points.append(pt - Vector2(16, 16))
        print("Local centered points: ", local_points)

extends SceneTree

func _init() -> void:
    var img = load("res://assets/island3/stalactites.png").get_image()
    var w = 192 / 6 # 32
    var h = 1920 / 30 # 64
    
    for f in range(6 * 30):
        var fx = (f % 6) * w
        var fy = int(f / 6) * h
        var has_pixels = false
        for y in range(h):
            for x in range(w):
                if img.get_pixel(fx + x, fy + y).a > 0.1:
                    has_pixels = true
                    break
            if has_pixels: break
            
        if has_pixels:
            print("Found visible frame at index: ", f, " (", fx, ", ", fy, ")")
            
    quit()

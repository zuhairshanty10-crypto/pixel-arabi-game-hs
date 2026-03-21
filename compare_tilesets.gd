@tool
extends SceneTree

func _init():
    var paths = [
        "res://assets/island1/Tileset.png",
        "C:/Users/User/Desktop/island3/TILED_files/Tileset.png"
    ]
    for p in paths:
        var img = Image.load_from_file(p)
        if img:
            print("%s: %dx%d" % [p, img.get_width(), img.get_height()])
        else:
            print("%s: FAILED" % p)
    quit()

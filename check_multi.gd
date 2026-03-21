@tool
extends SceneTree

func _init():
    var files = [
        "C:/Users/User/Desktop/island3/TILED_files/Objects.png",
        "C:/Users/User/Desktop/island3/TILED_files/Details.png",
        "C:/Users/User/Desktop/island3/TILED_files/Tileset.png"
    ]
    for f in files:
        var img = Image.load_from_file(f)
        if img:
            print("%s: %dx%d" % [f.get_file(), img.get_width(), img.get_height()])
        else:
            print("%s: FAILED" % f.get_file())
    quit()

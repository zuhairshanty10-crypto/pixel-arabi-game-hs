@tool
extends SceneTree

func _init():
    var img = Image.load_from_file("C:/Users/User/Desktop/island3/TILED_files/Tileset.png")
    if img:
        print("Dimensions: %dx%d" % [img.get_width(), img.get_height()])
    else:
        print("Failed to load image")
    quit()

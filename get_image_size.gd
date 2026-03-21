@tool
extends SceneTree

func _init():
    var img = Image.load_from_file("C:/Users/User/Desktop/island 1/1 Tiles/Tileset.png")
    if img:
        print("Small Tileset Size: %d x %d" % [img.get_width(), img.get_height()])
    
    var img2 = Image.load_from_file("c:/Users/User/Desktop/pixel arabi game hs/assets/island1/Tileset.png")
    if img2:
        print("Current Tileset Size: %d x %d" % [img2.get_width(), img2.get_height()])
    quit()

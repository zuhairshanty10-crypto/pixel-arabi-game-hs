extends SceneTree

func _init() -> void:
    print("Getting image sizes...")
    var chest = load("res://assets/island3/chest.png")
    if chest: print("Chest size: ", chest.get_width(), "x", chest.get_height())
    var key = load("res://assets/island3/key.png")
    if key: print("Key size: ", key.get_width(), "x", key.get_height())
    quit()

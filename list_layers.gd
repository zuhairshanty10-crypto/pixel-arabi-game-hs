@tool
extends SceneTree

func _init():
    var file = FileAccess.open("res://scenes/levels/Level_01.tscn", FileAccess.READ)
    if not file: quit()
    var content = file.get_as_text()
    
    var regex = RegEx.new()
    regex.compile("\\[node name=\"([^\"]+)\" type=\"TileMapLayer\"")
    var matches = regex.search_all(content)
    
    for m in matches:
        print("Layer: %s" % m.get_string(1))
    quit()

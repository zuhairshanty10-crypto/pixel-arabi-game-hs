extends SceneTree

func _init() -> void:
    if not InputMap.has_action("move_up"):
        InputMap.add_action("move_up")
        var up_key = InputEventKey.new()
        up_key.physical_keycode = KEY_W
        InputMap.action_add_event("move_up", up_key)
        var up_arrow = InputEventKey.new()
        up_arrow.physical_keycode = KEY_UP
        InputMap.action_add_event("move_up", up_arrow)

    if not InputMap.has_action("move_down"):
        InputMap.add_action("move_down")
        var down_key = InputEventKey.new()
        down_key.physical_keycode = KEY_S
        InputMap.action_add_event("move_down", down_key)
        var down_arrow = InputEventKey.new()
        down_arrow.physical_keycode = KEY_DOWN
        InputMap.action_add_event("move_down", down_arrow)

    ProjectSettings.save()
    print("Inputs added and saved!")
    quit()

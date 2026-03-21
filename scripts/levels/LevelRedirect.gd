extends Node2D

## Redirects to the original final level of the corresponding island.
## Sets a GameManager override so the ExitDoor chains to the next Island 5 level.
@export var target_level_path: String = ""
@export var next_island5_level: String = ""

func _ready() -> void:
	if target_level_path == "":
		return
	
	# Tell GameManager we're in Island 5
	if GameManager:
		GameManager.current_island = 5
		GameManager.set_meta("island5_next_level", next_island5_level)
	
	# Must use call_deferred - can't change scene during _ready()
	get_tree().call_deferred("change_scene_to_file", target_level_path)

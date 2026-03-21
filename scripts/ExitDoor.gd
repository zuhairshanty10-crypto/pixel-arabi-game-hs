extends Area2D

## Exit door that opens when the player reaches it and transitions to the next level.

@export var next_level_path: String = ""

@onready var sprite: Sprite2D = $Sprite2D

var is_opening: bool = false

# Exact pixel regions for each door frame (row 1: brown door)
var frame_regions = [
	Rect2(0, 0, 26, 32), # Frame 0: Closed
	Rect2(26, 0, 26, 32), # Frame 1: Half open (shifted right by 1px from 27 to 26 to center it)
	Rect2(53, 0, 27, 32), # Frame 2: Fully open (shifted right to 53, width 27)
]

func _ready() -> void:
	# Only set collision_mask if it wasn't disabled in the scene (decoy doors use mask=0)
	if collision_mask != 0:
		collision_mask = 2 # Player layer
	body_entered.connect(_on_body_entered)
	# Start with closed door
	sprite.region_enabled = true
	sprite.region_rect = frame_regions[0]

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.is_in_group("player") and not is_opening:
		_open_door()

func _open_door() -> void:
	is_opening = true
	AudioManager.play_sfx(load("res://assets/sounds/door.mp3"))
	
	# Animate door opening using exact pixel regions (no shifting!)
	sprite.region_rect = frame_regions[1]
	await get_tree().create_timer(0.2).timeout
	sprite.region_rect = frame_regions[2]
	await get_tree().create_timer(0.3).timeout
	
	# Complete the level
	var level_manager = _find_level_manager()
	if level_manager:
		level_manager.complete_level()
	
	# Check if this is the last level in Hardcore Mode
	if GameManager and GameManager.is_hardcore_mode:
		# Check if this is the final level (Island 5, Level 5)
		var is_final = (next_level_path == "" or (GameManager.current_island == 5 and GameManager.current_level == 5))
		if is_final:
			# Player beat hardcore mode! Show win screen
			var players = get_tree().get_nodes_in_group("player")
			if players.size() > 0 and players[0].has_method("show_hardcore_win"):
				players[0].show_hardcore_win()
			return
	
	# Transition to next level
	# Check if Island 5 redirect is active
	if GameManager and GameManager.has_meta("island5_next_level"):
		var override_path = GameManager.get_meta("island5_next_level")
		GameManager.remove_meta("island5_next_level")
		if override_path != "":
			get_tree().change_scene_to_file(override_path)
			return
	
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
	else:
		print("No next level set! Set 'Next Level Path' in the Inspector.")

func _find_level_manager() -> LevelManager:
	var node = get_parent()
	while node:
		if node is LevelManager:
			return node
		node = node.get_parent()
	return null

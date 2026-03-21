extends Node2D
class_name LevelManager

# Manages the logic for a specific level.
# Tracks level time, stars collected, and interacts with the global GameManager.

@export var island_id: int = 1
@export var level_id: int = 1
@export var par_time: float = 30.0 # Time needed for 3 stars
@export var two_star_time: float = 60.0 # Time needed for 2 stars

var level_time: float = 0.0
var level_started: bool = false
var level_completed: bool = false

func _ready() -> void:
	var scene_file = get_tree().current_scene.scene_file_path
	if scene_file:
		var fn = scene_file.get_file().get_basename()
		if fn.begins_with("Level_"):
			var parts = fn.trim_prefix("Level_").split("_")
			if parts.size() == 2:
				# Format: Level_I_L (e.g., Level_2_1)
				island_id = parts[0].to_int()
				level_id = parts[1].to_int()
			elif parts.size() == 1:
				# Format: Level_X (e.g., Level_01)
				var abs_level = parts[0].to_int()
				if abs_level > 0:
					island_id = ((abs_level - 1) / 5) + 1
					level_id = ((abs_level - 1) % 5) + 1

	if GameManager:
		GameManager.current_island = island_id
		GameManager.current_level = level_id
		
		var player = get_node_or_null("Player")
		if player:
			GameManager.spawn_position = player.global_position
			
			# Set camera bottom limit based on BottomBoundary
			var bottom_boundary = get_node_or_null("BottomBoundary")
			if not bottom_boundary:
				bottom_boundary = get_node_or_null("BottomBoundary2") # For Level_2_2 naming
			
			if bottom_boundary and player.has_node("Camera2D"):
				var cam = player.get_node("Camera2D")
				# Limit camera so it doesn't go below the boundary
				# Limit camera so it doesn't go below the boundary
				cam.limit_bottom = int(bottom_boundary.global_position.y)
				
			var level_label = player.get_node_or_null("HUD/MarginContainer/HBoxContainer/LevelLabel")
			if level_label:
				level_label.text = "Level %d-%d" % [island_id, level_id]
				
	# Play correct background music
	if AudioManager:
		if island_id == 1:
			AudioManager.play_island1_music()
		elif island_id == 2:
			AudioManager.play_island2_music()
		elif island_id == 4:
			AudioManager.play_island4_music()
		else:
			AudioManager.stop_music()

	# Start timer automatically for now
	start_level()

func _process(delta: float) -> void:
	if level_started and not level_completed:
		level_time += delta

func start_level() -> void:
	level_started = true
	level_time = 0.0

func complete_level() -> void:
	if level_completed: return
	level_completed = true
	level_started = false
	
	# Calculate stars based on time
	var stars = 1
	if level_time <= par_time:
		stars = 3
	elif level_time <= two_star_time:
		stars = 2
		
	# Pass to GameManager
	if GameManager:
		GameManager.complete_level(level_time)

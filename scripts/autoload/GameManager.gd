extends Node

## Global game state manager (Autoload)

# Current selection
var current_island: int = 1
var current_level: int = 1

# Death tracking
var deaths_this_level: int = 0
var deaths_total: int = 0

# Hardcore Mode
var is_hardcore_mode: bool = false
var hardcore_lives: int = 5
var hardcore_attempts_left: int = 5

# Level completion data: { "island-level": { "completed": bool, "stars": int, "best_time": float, "deaths": int } }
# Example key: "1-1", "2-3"
var level_data: Dictionary = {}

var spawn_position: Vector2 = Vector2.ZERO

signal player_died
signal level_completed(stars: int)
signal level_started

func _ready() -> void:
	# Initialize level data for 5 islands * 5 levels
	for i in range(1, 6):
		for l in range(1, 6):
			var key = str(i) + "-" + str(l)
			level_data[key] = {
				"completed": false,
				"stars": 0,
				"best_time": 999.0,
				"deaths": 0
			}
	
	# For testing, let's unlock the first level of island 1 explicitly
	# Or just rely on is_level_unlocked logic

func reset_level() -> void:
	deaths_this_level = 0
	level_started.emit()

func on_player_death() -> void:
	deaths_this_level += 1
	deaths_total += 1
	
	if is_hardcore_mode:
		hardcore_lives -= 1
		
	if SaveManager: SaveManager.save_game()
	player_died.emit()

func start_hardcore_run() -> void:
	is_hardcore_mode = true
	hardcore_lives = 5
	# Reset progress for the hardcore run
	for key in level_data:
		level_data[key]["completed"] = false
		level_data[key]["stars"] = 0
		level_data[key]["best_time"] = 999.0
		level_data[key]["deaths"] = 0
	
	deaths_total = 0
	current_island = 1
	current_level = 1
	if SaveManager: SaveManager.save_game()

func reset_hardcore_and_fail() -> void:
	is_hardcore_mode = false
	hardcore_lives = 5
	# Wipe data and go back to normal
	for key in level_data:
		level_data[key]["completed"] = false
	if SaveManager: SaveManager.save_game()

func complete_level(time: float) -> void:
	var stars = 1
	var target_time = 45.0
	if time <= target_time: stars = 2
	if deaths_this_level == 0: stars = 3
	
	var key = str(current_island) + "-" + str(current_level)
	if not level_data.has(key):
		level_data[key] = {}
		
	var data = level_data[key]
	data["completed"] = true
	if stars > data.get("stars", 0): data["stars"] = stars
	if time < data.get("best_time", 999.0): data["best_time"] = time
	data["deaths"] = min(deaths_this_level, data.get("deaths", 999))
	
	if SaveManager: SaveManager.save_game()
	level_completed.emit(stars)

func is_level_unlocked(island: int, level: int) -> bool:
	if island == 1 and level == 1:
		return true
		
	if level == 1:
		# To unlock a new island, the previous island's level 5 must be completed
		var prev_key = str(island - 1) + "-5"
		return level_data.get(prev_key, {}).get("completed", false)
	else:
		# To unlock a level, the previous level on the same island must be completed
		var prev_key = str(island) + "-" + str(level - 1)
		return level_data.get(prev_key, {}).get("completed", false)

func is_island_unlocked(island: int) -> bool:
	if island == 1: return true
	return is_level_unlocked(island, 1)

extends Area2D

# Fake Door: Runs away when approached, but becomes real at the final point

@export var teleport_distance: float = 120.0
@export var speed: float = 600.0
@export var next_level_path: String = ""

var current_target_idx: int = 0
@export var teleport_points: Array[NodePath]

@onready var sprite = $Sprite2D
@onready var sfx = $SFX_Teleport
@onready var collision = $CollisionShape2D

var points_nodes = []
var is_moving = false
var target_pos = Vector2.ZERO
var player_ref = null

var is_fake: bool = true
var is_opening: bool = false

var frame_regions = [
	Rect2(0, 0, 26, 32),
	Rect2(26, 0, 26, 32),
	Rect2(53, 0, 27, 32)
]

var initial_position: Vector2

func _ready():
	add_to_group("trap")
	body_entered.connect(_on_body_entered)
	
	initial_position = global_position
	
	# Resolve node paths
	for p in teleport_points:
		if p and get_node_or_null(p):
			points_nodes.append(get_node(p))

# Called by GameManager or Player when respawning
func _reset_trap() -> void:
	global_position = initial_position
	current_target_idx = 0
	is_fake = true
	is_moving = false
	is_opening = false
	collision.set_deferred("disabled", false)
	sprite.scale = Vector2(3, 3)
	sprite.region_rect = frame_regions[0]
	target_pos = Vector2.ZERO

func _process(delta):
	# Find player if not cached
	if not player_ref:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player_ref = players[0]
			
	# Move towards target if active
	if is_moving:
		global_position = global_position.move_toward(target_pos, speed * delta)
		if global_position.distance_to(target_pos) < 5:
			is_moving = false
			collision.disabled = false # Re-enable trigger
			
	# Check distance to player to trigger teleport (only if it's still fake)
	if is_fake and not is_moving and player_ref and not player_ref.is_dead:
		if global_position.distance_to(player_ref.global_position) < teleport_distance:
			trigger_teleport()

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_ref = body
		if is_fake:
			trigger_teleport()
		elif not is_opening:
			_open_door()

func _on_body_exited(body):
	if body == player_ref:
		player_ref = null

func trigger_teleport():
	if not is_fake: return
	
	if points_nodes.size() > 0:
		if current_target_idx < points_nodes.size():
			# Go to next point
			target_pos = points_nodes[current_target_idx].global_position
			current_target_idx += 1
		else:
			# Reached the end! Become a real door
			is_fake = false
			return
	else:
		# Jump up randomly if no points set
		target_pos = global_position + Vector2(randf_range(-100, 100), -150)
		
	is_moving = true
	collision.set_deferred("disabled", true) # Prevent multi-triggers
	
	if sfx and not sfx.playing:
		sfx.pitch_scale = randf_range(0.8, 1.2)
		sfx.play()
		
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(4, 0.1), 0.1)
	tween.tween_property(sprite, "scale", Vector2(3, 3), 0.2)

func _open_door() -> void:
	is_opening = true
	# Re-use global audio manager or just play sfx
	if AudioManager: AudioManager.play_sfx(load("res://assets/sounds/door.mp3"))
	
	sprite.region_rect = frame_regions[1]
	await get_tree().create_timer(0.2).timeout
	sprite.region_rect = frame_regions[2]
	await get_tree().create_timer(0.3).timeout
	
	# Complete the level (Crucial for unlocking subsequent islands/levels)
	var level_manager = _find_level_manager()
	if level_manager:
		level_manager.complete_level()
	
	# Transition
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

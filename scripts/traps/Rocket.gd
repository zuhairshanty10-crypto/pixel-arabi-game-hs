extends CharacterBody2D

# The Rocket follows the player until it hits something.
# Uses direct position movement to avoid CharacterBody2D collision bugs on spawn.

@export var speed: float = 300.0
@export var turn_speed: float = 3.0
@export var detection_radius: float = 400.0


var target: Node2D = null
var is_active: bool = false
var original_position: Vector2
var original_rotation: float
var is_destroyed: bool = false
var current_velocity: Vector2 = Vector2.ZERO


@onready var sprite: Sprite2D = $Sprite2D
@onready var kill_area: Area2D = $KillArea

func _ready() -> void:
	# Disable ALL physics collision on this body - we move manually
	collision_layer = 0
	collision_mask = 0
	
	add_to_group("trap")
	
	kill_area.collision_mask = 2 # Player
	kill_area.body_entered.connect(_on_kill)
	
	original_position = global_position
	original_rotation = rotation
	
	# Connect to GameManager for hide on player death
	if GameManager:
		GameManager.player_died.connect(_hide_rocket)

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
		
	if not is_active:
		_search_for_target()
		return
	
	if not target or not is_instance_valid(target):
		_hide_rocket()
		return
	
	
	# Homing logic
	var desired_velocity = global_position.direction_to(target.global_position) * speed
	current_velocity = current_velocity.lerp(desired_velocity, turn_speed * delta)
	
	# Move using direct position (NOT move_and_collide)
	global_position += current_velocity * delta
	
	# Rotate sprite towards movement direction
	rotation = current_velocity.angle()
	
	# Flip sprite vertically when going left so it doesn't appear upside down
	if current_velocity.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func _search_for_target() -> void:
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		if global_position.distance_to(p.global_position) < detection_radius:
			target = p
			is_active = true
			break

func _on_kill(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die"):
		# Explode FIRST, then kill player
		# This way we hide the rocket exactly as the player dies
		explode()
		body.die()

func explode() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	
	# Camera shake
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_camera"):
		camera.shake_camera(6.0, 0.2)
	
	_hide_rocket()

func _hide_rocket() -> void:
	is_destroyed = true
	visible = false
	set_physics_process(false)
	kill_area.get_node("CollisionShape2D").set_deferred("disabled", true)

func _reset_trap() -> void:
	is_destroyed = false
	is_active = false
	target = null
	current_velocity = Vector2.ZERO
	global_position = original_position
	rotation = original_rotation
	sprite.flip_v = false
	visible = true
	set_physics_process(true)
	kill_area.get_node("CollisionShape2D").set_deferred("disabled", false)

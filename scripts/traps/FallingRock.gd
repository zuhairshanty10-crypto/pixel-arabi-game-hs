extends TrapBase

# A rock/stalactite that hangs and falls when the player walks under it

@export var fall_gravity: float = 2500.0 # Much faster fall speed
@export var trigger_distance_y: float = 500.0
@export var trigger_distance_x: float = 60.0

var is_falling: bool = false
var has_fallen: bool = false
var current_velocity: float = 0.0
var original_y: float

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _trap_init() -> void:
	original_y = global_position.y
	# Enable collision with World (Layer 1) and Player (Layer 2)
	collision_mask = 3
	
	# Listen for respawn
	if GameManager:
		GameManager.level_started.connect(reset_rock)
		# We wait a split second for the player to fully die before resetting traps so we don't snap the rock while the death animation is playing.
		GameManager.player_died.connect(func(): await get_tree().create_timer(0.6).timeout; reset_rock())

func _physics_process(delta: float) -> void:
	if has_fallen:
		return
		
	if is_falling:
		current_velocity += fall_gravity * delta
		global_position.y += current_velocity * delta
		
		# Auto destroy if it falls way off screen to prevent lag
		if global_position.y > original_y + 1500:
			shatter()
	else:
		_check_for_player()

func _check_for_player() -> void:
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var diff = p.global_position - global_position
		# If player is below the rock and within horizontal range
		if diff.y > 0 and diff.y < trigger_distance_y and abs(diff.x) < trigger_distance_x:
			trigger_fall()
			break

func trigger_fall() -> void:
	is_falling = true

func _on_body_entered(body: Node2D) -> void:
	if has_fallen or not is_falling:
		return
		
	# If hitting player, let TrapBase handle killing
	if body.is_in_group("player"):
		super._on_body_entered(body) # This triggers player.die() inside TrapBase
		shatter()
	else:
		# Hit floor or something else (like TileMapLayer)
		shatter()

func shatter() -> void:
	if not has_fallen:
		AudioManager.play_sfx(load("res://assets/sounds/stone.mp3"))
	is_falling = false
	has_fallen = true
	sprite.visible = false
	collision.set_deferred("disabled", true)

func reset_rock() -> void:
	global_position.y = original_y
	current_velocity = 0.0
	is_falling = false
	has_fallen = false
	sprite.visible = true
	collision.set_deferred("disabled", false)

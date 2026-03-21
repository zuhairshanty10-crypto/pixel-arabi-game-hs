extends TrapBase

@export var fuse_time: float = 1.0
@export var explosion_radius: float = 60.0

var is_triggered: bool = false
var is_exploded: bool = false
var original_position: Vector2
@onready var explosion_area: Area2D = $ExplosionArea
@onready var sprite: Sprite2D = $Sprite2D

func _trap_init() -> void:
	kill_on_contact = false
	original_position = global_position
	
	explosion_area.collision_layer = 4
	explosion_area.collision_mask = 2
	explosion_area.body_entered.connect(_on_explosion_hit)
	
	# Connect to GameManager for reset on player death
	if GameManager:
		GameManager.player_died.connect(_reset_bomb)

func _on_player_entered(player: Node2D) -> void:
	if not is_triggered:
		trigger_bomb()

func trigger_bomb() -> void:
	is_triggered = true
	
	# Simple frame progression (Bomb.png has ~5 frames)
	for i in range(1, 4):
		if not is_instance_valid(self ) or is_exploded: return
		sprite.frame = i
		await get_tree().create_timer(fuse_time / 4.0).timeout
	
	# Check if we were reset during the await (player died from something else)
	if not is_triggered or is_exploded:
		return
	
	explode()

func explode() -> void:
	if is_exploded:
		return
	is_exploded = true
	
	# Hide bomb sprite
	sprite.visible = false
	
	# Enable explosion hitbox temporarily
	explosion_area.get_node("CollisionShape2D").set_deferred("disabled", false)
	
	# Camera shake
	var camera = get_tree().get_first_node_in_group("camera")
	if camera and camera.has_method("shake_camera"):
		camera.shake_camera(8.0, 0.3)
	
	# The explosion hitbox will call _on_explosion_hit which calls die()
	# die() triggers player_died signal which calls _reset_bomb()
	# So we do NOT await here - _reset_bomb handles the full reset

func _reset_bomb() -> void:
	# Reset bomb to original state completely
	is_triggered = false
	is_exploded = false
	global_position = original_position
	sprite.frame = 0
	sprite.visible = true
	visible = true
	set_physics_process(true)
	monitoring = true
	explosion_area.get_node("CollisionShape2D").set_deferred("disabled", true)

func _on_explosion_hit(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die"):
		body.die()

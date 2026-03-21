extends StaticBody2D

# Fake Floor - looks like a tile but breaks when stepped on

@export var break_delay: float = 0.4
@export var respawn_time: float = 3.0
@export var is_permanent: bool = false # If true, never respawns

var is_broken: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $TriggerArea
@onready var particles: CPUParticles2D = $CPUParticles2D

func _ready() -> void:
	collision_layer = 1 # Solid world
	trigger_area.collision_mask = 2 # Detect player
	trigger_area.body_entered.connect(_on_player_step)

func _on_player_step(body: Node2D) -> void:
	if not is_broken and body is CharacterBody2D:
		# Small visual shake or darken
		sprite.modulate = Color(0.8, 0.8, 0.8)
		
		# Wait
		await get_tree().create_timer(break_delay).timeout
		break_floor()

func break_floor() -> void:
	if is_broken: return
	is_broken = true
	
	# Visuals
	sprite.visible = false
	if particles:
		particles.restart()
	
	# Physics
	collision.set_deferred("disabled", true)
	
	# Respawn logic
	if not is_permanent:
		await get_tree().create_timer(respawn_time).timeout
		restore_floor()

func restore_floor() -> void:
	is_broken = false
	sprite.visible = true
	sprite.modulate = Color(1, 1, 1)
	collision.set_deferred("disabled", false)

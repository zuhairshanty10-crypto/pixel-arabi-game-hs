extends Node2D

@export var move_distance: Vector2 = Vector2(100, 0)
@export var move_duration: float = 2.0
@export var start_delay: float = 0.0

@onready var platform: AnimatableBody2D = $Platform

var original_pos: Vector2
var target_pos: Vector2
var time_passed: float = 0.0
var is_active: bool = false

func _ready() -> void:
	# Ensure sync_to_physics is explicitly forced on
	platform.sync_to_physics = true
	
	original_pos = platform.position
	target_pos = original_pos + move_distance
	
	if start_delay > 0:
		set_physics_process(false)
		await get_tree().create_timer(start_delay).timeout
		set_physics_process(true)
		
	is_active = true

func _physics_process(delta: float) -> void:
	if not is_active: return
	
	time_passed += delta
	
	# Create a smooth back-and-forth ping-pong effect using sine wave math
	var progress = fmod(time_passed, move_duration * 2.0) / (move_duration * 2.0)
	var t = (sin(progress * PI * 2.0 - PI / 2.0) + 1.0) / 2.0
	
	# Explicitly modify internal platform position in physics step
	platform.position = original_pos.lerp(target_pos, t)

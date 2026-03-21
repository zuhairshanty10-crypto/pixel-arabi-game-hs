extends Node2D

@export var shoot_interval: float = 2.0
@export var arrow_speed: float = 400.0
@export var arrow_direction: Vector2 = Vector2(-1, 0)
@export var start_delay: float = 0.0

@onready var timer: Timer = $Timer
@onready var sprite: Sprite2D = $Sprite2D

var arrow_scene: PackedScene = preload("res://scenes/traps/Arrow.tscn")

func _ready() -> void:
	# Rotate shooter based on direction
	rotation = arrow_direction.angle()
	
	timer.wait_time = shoot_interval
	timer.timeout.connect(_on_shoot)
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
	timer.start()

func _on_shoot() -> void:
	# Play shooting animation if it has frames
	if sprite.hframes > 1 and sprite.vframes > 1:
		sprite.frame = 1
		await get_tree().create_timer(0.2).timeout
		sprite.frame = 0
	
	# Spawn arrow
	var arrow = arrow_scene.instantiate()
	get_parent().add_child(arrow)
	
	arrow.global_position = global_position
	arrow.direction = arrow_direction
	arrow.speed = arrow_speed
	arrow.rotation = arrow_direction.angle()

extends TrapBase

@export var cycle_time_on: float = 2.0
@export var cycle_time_off: float = 1.5
@export var start_delay: float = 0.0
@export var is_always_on: bool = false

var is_active: bool = false
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _trap_init() -> void:
	if is_always_on:
		turn_on()
	else:
		turn_off()
		if start_delay > 0:
			await get_tree().create_timer(start_delay).timeout
		_start_cycle()

func _start_cycle() -> void:
	while not is_always_on:
		turn_on()
		await get_tree().create_timer(cycle_time_on).timeout
		turn_off()
		await get_tree().create_timer(cycle_time_off).timeout

func turn_on() -> void:
	is_active = true
	sprite.visible = true
	sprite.play("burn")
	collision.set_deferred("disabled", false)

func turn_off() -> void:
	is_active = false
	sprite.visible = false
	sprite.stop()
	collision.set_deferred("disabled", true)

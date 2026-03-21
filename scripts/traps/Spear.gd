extends TrapBase

# A spear that periodically thrusts out of a block/wall

@export var extend_duration: float = 0.2
@export var retract_duration: float = 0.5
@export var wait_extended: float = 1.0
@export var wait_retracted: float = 2.0
@export var extend_distance: Vector2 = Vector2(0, -64) # Default extends upward
@export var start_delay: float = 0.0

@onready var spear_body: Node2D = $SpearBody
var base_position: Vector2

func _trap_init() -> void:
	base_position = spear_body.position
	
	if start_delay > 0:
		await get_tree().create_timer(start_delay).timeout
		
	_start_cycle()

func _start_cycle() -> void:
	while true:
		var tween = create_tween()
		
		# Extend
		tween.tween_property(spear_body, "position", base_position + extend_distance, extend_duration).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished
		
		# Wait
		await get_tree().create_timer(wait_extended).timeout
		
		# Retract
		tween = create_tween()
		tween.tween_property(spear_body, "position", base_position, retract_duration).set_trans(Tween.TRANS_SINE)
		await tween.finished
		
		# Wait
		await get_tree().create_timer(wait_retracted).timeout

extends TrapBase

# A circular saw blade that rotates endlessly and optionally moves between two points.

@export var rotation_speed: float = 15.0
@export var move_distance: Vector2 = Vector2(0, 0) # If (0,0), it just spins in place
@export var move_duration: float = 2.0

@onready var sprite: Sprite2D = $Sprite2D

func _trap_init() -> void:
	if move_distance != Vector2.ZERO:
		var tween = create_tween().set_loops()
		var original_pos = position
		var target_pos = original_pos + move_distance
		
		# Move back and forth
		tween.tween_property(self , "position", target_pos, move_duration).set_trans(Tween.TRANS_SINE)
		tween.tween_property(self , "position", original_pos, move_duration).set_trans(Tween.TRANS_SINE)

func _physics_process(delta: float) -> void:
	# Spin the sprite
	sprite.rotation += rotation_speed * delta

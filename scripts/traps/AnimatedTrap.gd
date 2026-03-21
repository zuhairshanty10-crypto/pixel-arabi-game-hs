extends Area2D

## Animated sprite-sheet trap that kills the player on contact.
## Works with horizontal sprite sheets — set hframes on the Sprite2D child.

@export var trap_damage_enabled: bool = true
@export var animation_fps: float = 12.0
@export var loop_animation: bool = true

var _frame: int = 0
var _time: float = 0.0
var _sprite: Sprite2D = null

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 0
	collision_mask = 2 # Player layer
	
	# Find the child Sprite2D
	for child in get_children():
		if child is Sprite2D:
			_sprite = child
			break

func _process(delta):
	if _sprite == null or _sprite.hframes <= 1:
		return
	_time += delta
	var frame_duration = 1.0 / animation_fps
	if _time >= frame_duration:
		_time -= frame_duration
		_frame += 1
		if _frame >= _sprite.hframes:
			if loop_animation:
				_frame = 0
			else:
				_frame = _sprite.hframes - 1
		_sprite.frame = _frame

func _on_body_entered(body):
	if trap_damage_enabled and body.name == "Player" and body.has_method("die"):
		body.die()

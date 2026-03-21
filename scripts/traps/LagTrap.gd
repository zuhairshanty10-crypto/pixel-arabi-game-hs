extends Area2D

@export var duration: float = 8.0
@export var target_fps: int = 5

var effect_active = false
var _sprite: Sprite2D = null
var _frame: float = 0.0
@export var animation_fps: float = 12.0

func _ready():
	for child in get_children():
		if child is Sprite2D:
			_sprite = child
			break

func _process(delta):
	if _sprite and _sprite.hframes > 1:
		_frame += animation_fps * delta
		var max_frames = _sprite.hframes
		if _frame >= max_frames:
			_frame = 0
		var frame_int = int(_frame)
		if frame_int == 11: frame_int = 12
		_sprite.frame = min(frame_int, max_frames - 1)

func _on_body_entered(body):
	if body.is_in_group("player") and not effect_active:
		effect_active = true
		_apply_lag()

func _apply_lag():
	# Store original values
	var original_time_scale = Engine.time_scale
	
	# Slow the entire engine to simulate lag
	Engine.time_scale = 0.2  # adjusted for 5 FPS feel
	Engine.max_fps = target_fps
	
	# We need a real-world timer, not an in-game timer (since time_scale affects timers)
	# Use a separate thread-safe approach
	var start_time = Time.get_ticks_msec()
	
	while Time.get_ticks_msec() - start_time < duration * 1000:
		await get_tree().process_frame
	
	# Restore normal speed
	Engine.time_scale = 1.0
	Engine.max_fps = 0  # 0 = unlimited (default)
	effect_active = false

func _reset_trap():
	Engine.time_scale = 1.0
	Engine.max_fps = 0
	effect_active = false

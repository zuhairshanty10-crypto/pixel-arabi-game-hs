extends Area2D

@export_enum("teleport_up", "invert_controls") var effect_type: String = "invert_controls"

var _sprite: Sprite2D = null
var _frame: float = 0.0
@export var animation_fps: float = 12.0

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 4
	collision_mask = 2
	
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
		# Skip frame 11 as it's a completely transparent glitch frame based on pixel analysis
		if frame_int == 11:
			frame_int = 12
			
		_sprite.frame = min(frame_int, max_frames - 1)

func _on_body_entered(body):
	if body.name == "Player":
		# Teleport high into the air
		if effect_type == "teleport_up":
			body.global_position.y -= 1000
			body.velocity.y = 0
			
		# Troll the player by reversing their controls for 4 seconds
		elif effect_type == "invert_controls":
			if "controls_inverted" in body and not body.controls_inverted:
				body.controls_inverted = true
				
				# Give a visual cue (turn player slightly purple)
				if body.has_node("AnimatedSprite2D"):
					var player_sprite = body.get_node("AnimatedSprite2D")
					player_sprite.modulate = Color(0.8, 0.2, 1.0)
				
				var timer = get_tree().create_timer(10.0)
				timer.timeout.connect(func():
					if is_instance_valid(body):
						body.controls_inverted = false
						if body.has_node("AnimatedSprite2D"):
							body.get_node("AnimatedSprite2D").modulate = Color.WHITE
				)

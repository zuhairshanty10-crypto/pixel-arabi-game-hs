extends Area2D

@export var knockback_force: Vector2 = Vector2(0, -1100) # Strong uppercut force

var _punching: bool = false
var _sprite: Sprite2D = null
var _punch_frame: float = 0.0
@onready var animation_fps: float = 24.0

# The visible frames based on pixel analysis
# Note: Frame 0 is transparent (hidden)
var visible_frames = [1, 4, 7, 10, 13, 16, 19, 22, 25, 28, 31, 34, 37]

func _ready():
	body_entered.connect(_on_body_entered)
	collision_layer = 4 # Trap
	collision_mask = 2 # Player
	
	for child in get_children():
		if child is Sprite2D:
			_sprite = child
			break
			
	if _sprite:
		_sprite.frame = 0 # Start completely hidden for surprise hit

func _process(delta):
	if _punching and _sprite:
		_punch_frame += animation_fps * delta
		var max_index = visible_frames.size() - 1
		
		# If animation is done, go back to hidden
		if int(_punch_frame) > max_index:
			_punching = false
			_sprite.frame = 0
		else:
			_sprite.frame = visible_frames[int(_punch_frame)]

func do_punch(player):
	if _punching:
		return
		
	_punching = true
	_punch_frame = 0.0
	
	_apply_knockback(player)

func _on_body_entered(body):
	# If player walks into the hidden trap
	if body.name == "Player":
		do_punch(body)

func _apply_knockback(player):
	# Push player away from trap
	var dir = sign(player.global_position.x - global_position.x)
	if dir == 0:
		dir = 1
	
	player.velocity = Vector2(abs(knockback_force.x) * dir, knockback_force.y)
	
	if player.has_method("shake_camera"):
		player.shake_camera(6.0, 0.2)

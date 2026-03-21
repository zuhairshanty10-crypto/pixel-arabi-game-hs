extends StaticBody2D

## Shoots arrows at regular intervals.
## The trap itself kills on touch if the player hits the block.

@export var shoot_interval: float = 2.0
@export var arrow_speed: float = 400.0
@export var arrow_direction: Vector2 = Vector2.RIGHT
@export var arrow_scene: PackedScene

var _time: float = 0.0
var _sprite: Sprite2D = null
var _shooting: bool = false
var _shoot_frame: float = 0.0

@onready var animation_fps: float = 24.0

func _ready():
	collision_layer = 1 # Solid block
	collision_mask = 2 # Player layer
	
	for child in get_children():
		if child is Sprite2D:
			_sprite = child
			break
			
	if _sprite:
		_sprite.frame = 1
		
	if not arrow_scene:
		arrow_scene = load("res://scenes/traps/Arrow.tscn")

func _process(delta):
	_time += delta
	
	# Handle shooting animation
	if _shooting and _sprite:
		_shoot_frame += animation_fps * delta
		var visible_frames = [1, 4, 7, 10, 13, 16, 19, 22, 25, 27, 28, 31, 34, 37, 40, 43, 46, 49]
		var max_index = visible_frames.size() - 1
		
		if int(_shoot_frame) > max_index:
			_shooting = false
			_sprite.frame = visible_frames[0] # Go back to idle visible frame
		else:
			_sprite.frame = visible_frames[int(_shoot_frame)]
			
	# Trigger new shot
	if _time >= shoot_interval:
		_time = 0.0
		shoot_arrow()

func shoot_arrow():
	_shooting = true
	_shoot_frame = 0.0
	
	if arrow_scene:
		var arrow = arrow_scene.instantiate()
		get_parent().add_child(arrow)
		
		# Set arrow position to the trap's center, slightly offset in the direction
		arrow.global_position = global_position + (arrow_direction * 10)
		
		# Configure the arrow properties
		if arrow.has_method("_trap_init") or "direction" in arrow:
			arrow.direction = arrow_direction
			arrow.speed = arrow_speed
			# Force init to set velocity
			if arrow.has_method("_trap_init"):
				arrow._trap_init()

func _on_body_entered(body):
	pass # Trap structure doesn't kill you, only the arrows do!

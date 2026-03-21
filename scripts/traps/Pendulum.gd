extends Area2D

@export var swing_speed: float = 2.0
@export var swing_angle: float = 60.0 # in degrees
@export var start_offset: float = 0.0 # Phase offset for timing different pendulums

var time_passed: float = 0.0
var max_angle_rad: float = 0.0

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer

func _ready():
	max_angle_rad = deg_to_rad(swing_angle)
	time_passed = start_offset
	
	if animation_player:
		animation_player.play("swing")

func _physics_process(delta):
	time_passed += delta * swing_speed
	
	# Sine wave swinging movement
	rotation = sin(time_passed) * max_angle_rad

func _on_body_entered(body):
	if body.is_in_group("player") and body.has_method("die"):
		body.die()

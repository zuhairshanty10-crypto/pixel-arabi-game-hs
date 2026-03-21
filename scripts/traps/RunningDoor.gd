extends Area2D

# A goal door that runs away when the player gets close

@export var trigger_distance: float = 200.0
@export var run_speed: float = 400.0
@export var stop_after_distance: float = 1000.0

var is_running: bool = false
var distance_run: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D

var start_pos: Vector2

func _ready() -> void:
	start_pos = position
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_reached)
	if GameManager:
		GameManager.player_died.connect(reset_trap)

func reset_trap() -> void:
	position = start_pos
	is_running = false
	distance_run = 0.0

func _physics_process(delta: float) -> void:
	if not is_running:
		_check_player_distance()
	else:
		if distance_run < stop_after_distance:
			var move = run_speed * delta
			position.x += move
			distance_run += move
		else:
			is_running = false

func _check_player_distance() -> void:
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var diff = position.x - p.position.x
		# If player is approaching from the left
		if diff > 0 and diff < trigger_distance and abs(position.y - p.position.y) < 100:
			is_running = true
			break

func _on_reached(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die"):
		# In this game, sometimes even the door is a trap!
		# Or maybe it just completes the level. Up to the level designer.
		# For maximum troll, it kills you the first time you catch it.
		if GameManager:
			GameManager.complete_level(0.0)

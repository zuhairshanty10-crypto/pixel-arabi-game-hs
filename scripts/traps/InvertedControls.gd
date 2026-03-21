extends Area2D

@export var is_one_shot: bool = true
@export var invert_duration: float = 0.0 # 0 means permanent until they hit another one

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_player_entered)

func _on_player_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_property("controls_inverted"):
		body.controls_inverted = not body.controls_inverted
		
		# Temporary invert
		if invert_duration > 0:
			await get_tree().create_timer(invert_duration).timeout
			if is_instance_valid(body):
				body.controls_inverted = false
		
		if is_one_shot:
			set_deferred("monitoring", false)

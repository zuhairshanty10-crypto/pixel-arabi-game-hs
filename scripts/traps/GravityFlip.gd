extends Area2D

@export var is_one_shot: bool = true

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_player_entered)

func _on_player_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_property("gravity_multiplier"):
		# Flip gravity
		body.gravity_multiplier *= -1
		
		# Flip sprite visually
		if body.has_node("AnimatedSprite2D"):
			var sprite = body.get_node("AnimatedSprite2D")
			sprite.flip_v = not sprite.flip_v
			
			# Adjust collision and sprite offset based on flip state
			var is_flipped = body.gravity_multiplier < 0
			sprite.position.y = 32 if is_flipped else -32
			
			var col = body.get_node("CollisionShape2D")
			col.position.y = 8 if is_flipped else -2
		
		# Disable if one shot
		if is_one_shot:
			set_deferred("monitoring", false)

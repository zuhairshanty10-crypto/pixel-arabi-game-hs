extends TrapBase

@export var bounce_force: float = -800.0

func _trap_init() -> void:
	kill_on_contact = false

func _on_player_entered(player: Node2D) -> void:
	if player is CharacterBody2D:
		# Reset falling speed, then bounce
		player.velocity.y = bounce_force
		
		# Allow player to dash again immediately after bouncing
		if player.has_property("can_dash"):
			player.can_dash = true
		
		# Tell sprite to play jump again
		if player.has_node("AnimatedSprite2D"):
			var sprite = player.get_node("AnimatedSprite2D")
			sprite.play("jump")

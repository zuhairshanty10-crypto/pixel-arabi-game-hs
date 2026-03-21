extends TrapBase

@export var push_force: float = -600.0

func _trap_init() -> void:
	kill_on_contact = false

func _physics_process(delta: float) -> void:
	# Keep pushing any connected player while they are inside the Area
	for body in get_overlapping_bodies():
		if body is CharacterBody2D and body.has_method("die"):
			_on_player_entered(body)

func _on_player_entered(player: Node2D) -> void:
	if player is CharacterBody2D:
		# Apply upward force continuously, overriding gravity
		player.velocity.y = push_force
		
		# Reset dash so player can maneuver out of the fan stream
		if player.has_property("can_dash"):
			player.can_dash = true

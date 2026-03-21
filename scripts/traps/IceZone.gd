extends Area2D

## Place this area on ice surfaces. When the player enters, they get slippery.

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.has_method("_physics_process") and body.has_meta("is_player") or body.name == "Player":
		body.on_ice = true

func _on_body_exited(body):
	if body.has_method("_physics_process") and body.has_meta("is_player") or body.name == "Player":
		body.on_ice = false

extends Area2D

## Put this at the top edge of your level.
## It acts as an invisible ceiling and automatically stops the camera from panning past it!

func _ready() -> void:
	# Wait one frame for the player/camera to be ready
	call_deferred("_set_camera_limit")

func _set_camera_limit() -> void:
	# Find the player in the current scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			# Set the top limit of the camera to this boundary's Y position
			# The camera won't be able to look further up!
			camera.limit_top = int(global_position.y)

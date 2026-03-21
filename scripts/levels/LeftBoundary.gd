extends StaticBody2D

## Put this at the far left edge of your level.
## It acts as an invisible wall, disables wall jumps on itself,
## and automatically stops the camera from panning past it!

func _ready() -> void:
	# Keep on collision layer 1 so it blocks the player
	# But we will give it a meta tag so the player knows NOT to wall-jump on it
	set_meta("no_wall_jump", true)
	
	# Wait one frame for the player/camera to be ready
	call_deferred("_set_camera_limit")

func _set_camera_limit() -> void:
	# Find the player in the current scene
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var camera = player.get_node_or_null("Camera2D")
		if camera:
			# Set the left limit of the camera to this boundary's X position
			# The camera won't be able to look further left!
			camera.limit_left = int(global_position.x)

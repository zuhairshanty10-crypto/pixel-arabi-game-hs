@tool
extends SceneTree

func _init():
	print("Adding Ladder Animations to Player...")
	
	var player_scene_path = "res://scenes/player/Player.tscn"
	var player_scene = load(player_scene_path) as PackedScene
	
	if not player_scene:
		print("Failed to load player scene.")
		quit()
		return
		
	var player_state = player_scene.get_state()
	var sf: SpriteFrames = null
	
	# Find the SpriteFrames resource in the scene's nodes
	for i in range(player_state.get_node_count()):
		if player_state.get_node_name(i) == "AnimatedSprite2D":
			for j in range(player_state.get_node_property_count(i)):
				if player_state.get_node_property_name(i, j) == "sprite_frames":
					sf = player_state.get_node_property_value(i, j)
					break
			break
			
	if not sf:
		print("Could not find SpriteFrames.")
		quit()
		return

	# Load textures
	var climb_tex = load("res://assets/player/Climbing Ladder.png")
	var descend_tex = load("res://assets/player/Descending Ladder.png")
	
	# Add climb animation
	if not sf.has_animation("climb"):
		sf.add_animation("climb")
		sf.set_animation_loop("climb", true)
		sf.set_animation_speed("climb", 10.0)
		for i in range(9):
			var at = AtlasTexture.new()
			at.atlas = climb_tex
			at.region = Rect2(i * 128, 0, 128, 128)
			sf.add_frame("climb", at)
			
	# Add descend animation
	if not sf.has_animation("descend"):
		sf.add_animation("descend")
		sf.set_animation_loop("descend", true)
		sf.set_animation_speed("descend", 10.0)
		for i in range(9):
			var at = AtlasTexture.new()
			at.atlas = descend_tex
			at.region = Rect2(i * 128, 0, 128, 128)
			sf.add_frame("descend", at)
			
	print("Added climb/descend animations. Saving the resource...")
	
	# Save the SpriteFrames resource (if it's internal to the scene, we might need a workaround, but Godot saves it attached)
	ResourceSaver.save(player_scene, player_scene_path)
	print("Saved player scene.")
	quit()

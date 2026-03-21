extends SceneTree
func _init():
	var scene = load('res://scenes/player/Player.tscn')
	if not scene: return
	var player = scene.instantiate()
	var sprite = player.get_node_or_null('AnimatedSprite2D')
	if sprite and sprite.sprite_frames:
		print("ANIMATIONS: ", sprite.sprite_frames.get_animation_names())
	else:
		print("NO ANIMATED SPRITE OR FRAMES")
	quit()

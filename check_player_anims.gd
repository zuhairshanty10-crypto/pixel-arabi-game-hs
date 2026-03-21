extends SceneTree
func _init():
	var scene = load('res://scenes/player/Player.tscn')
	if not scene: return
	var player = scene.instantiate()
	var ap = player.get_node_or_null('AnimationPlayer')
	if ap:
		print("ANIMATIONS: ", ap.get_animation_list())
	else:
		print("NO ANIMATION PLAYER")
	quit()

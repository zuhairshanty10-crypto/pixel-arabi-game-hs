extends SceneTree
func _init():
	var scene = load('res://scenes/enemies/Boss.tscn')
	if not scene: return
	var boss = scene.instantiate()
	var rc = boss.get_node_or_null('RightHandArea/CollisionShape2D')
	var lc = boss.get_node_or_null('LeftHandArea/CollisionShape2D')
	print("Right Col: ", rc)
	print("Left Col: ", lc)
	quit()

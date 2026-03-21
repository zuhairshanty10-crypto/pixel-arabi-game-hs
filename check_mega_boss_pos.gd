extends SceneTree
func _init():
	var scene = load('res://scenes/levels/Level_4_5.tscn')
	if not scene: return
	var level = scene.instantiate()
	var boss = level.get_node_or_null('Boss')
	if boss:
		print("BOSS NODE GLOBAL POS: ", boss.global_position)
		var sprite = boss.get_node_or_null('AnimatedSprite2D')
		if sprite:
			print("BOSS SPRITE OFFSET POS: ", sprite.position)
	else:
		print("NO BOSS NODE IN LEVEL_4_5")
	quit()

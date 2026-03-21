extends SceneTree
func _init():
	var scene = load('res://scenes/enemies/DarkKnightBoss.tscn')
	if scene:
		print('SUCCESS: DarkKnightBoss.tscn loaded!')
		var inst = scene.instantiate()
		print('Node: ' + inst.name)
		for child in inst.get_children():
			print('  Child: ' + child.name + ' (' + child.get_class() + ')')
	else:
		print('FAIL: Could not load DarkKnightBoss.tscn')
	quit()

extends SceneTree
func _init():
	var files = ['Idle', 'Walk', 'Run', 'Attack', 'Attack2', 'Attack3', 'Hurt', 'Death', 'Special', 'Jump', 'Walk_Attack']
	for f in files:
		var tex = load('res://assets/island4/enemies/DarkKnight/' + f + '.png')
		if tex:
			print(f + ': ' + str(tex.get_width()) + 'x' + str(tex.get_height()))
		else:
			print(f + ': NOT FOUND')
	quit()

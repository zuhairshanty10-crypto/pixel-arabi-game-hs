extends SceneTree
func _init():
	var files = ['Idle', 'Walk', 'Run', 'Attack', 'Attack2', 'Attack3', 'Hurt', 'Death', 'Special', 'Jump', 'Walk_Attack']
	for f in files:
		var img = Image.new()
		var err = img.load('res://assets/island4/enemies/DarkKnight/' + f + '.png')
		if err == OK:
			print(f + ': ' + str(img.get_width()) + 'x' + str(img.get_height()))
		else:
			print(f + ': LOAD ERROR ' + str(err))
	quit()

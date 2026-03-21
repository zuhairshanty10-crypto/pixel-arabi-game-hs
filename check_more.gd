extends SceneTree

func _init():
	var tex = load('res://assets/island4/enemies/RealBoss/Appearance.png')
	var tex2 = load('res://assets/island4/enemies/RealBoss/Special.png')
	if tex: print("Appearance width: ", tex.get_width()) 
	if tex2: print("Special width: ", tex2.get_width())
	quit()

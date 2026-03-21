extends SceneTree
func _init():
	var tex = load('res://assets/island4/enemies/RealBoss/Attack7_body.png')
	var tex2 = load('res://assets/island4/enemies/RealBoss/Attack7_laser.png')
	if tex: print("Attack7_body width: ", tex.get_width()) # Divided by 256 = frames
	if tex2: print("Attack7_laser width: ", tex2.get_width())
	quit()

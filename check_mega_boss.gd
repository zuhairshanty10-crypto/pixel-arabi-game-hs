extends SceneTree
func _init():
	var tex = load('res://assets/island4/enemies/RealBoss/Attack1.png')
	if not tex:
		print("NO TEX")
		quit()
		return
		
	var img = tex.get_image()
	# The image is 1536x256 (6 frames)
	print("Attack1 loaded. Size: ", img.get_width(), "x", img.get_height())
	quit()

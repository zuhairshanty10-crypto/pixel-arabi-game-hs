extends SceneTree
func _init():
	var scene = load('res://scenes/levels/Level_4_5.tscn')
	if not scene:
		print("FAILED TO LOAD LEVEL")
		quit()
		return
	var level = scene.instantiate()
	var boss = level.get_node('Boss')
	if boss:
		var sprite = boss.get_node('HeadSprite')
		print("Boss Pos: ", boss.position)
		if sprite:
			print("Boss Sprite Scale: ", sprite.scale, " Pos: ", sprite.position)
			print("Boss Sprite Region: ", sprite.texture.region if sprite.texture is AtlasTexture else "Not Atlas")
	quit()

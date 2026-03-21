extends SceneTree

func _init():
	var bg = ParallaxBackground.new()
	bg.name = 'Island4_Background'
	
	var base_path = 'res://assets/island4/tileset/2 Background/Night/'
	var scales = [0.1, 0.3, 0.5, 0.7, 0.9] # Scrolling speeds
	
	var tex1 = load(base_path + '1.png')
	var w = 576
	var h = 324
	if tex1:
		w = tex1.get_width()
		h = tex1.get_height()
		
	var scale_factor = max(1920.0 / w, 1080.0 / h)
	var scaled_w = w * scale_factor
	
	for i in range(1, 6):
		var pl = ParallaxLayer.new()
		pl.name = 'Layer' + str(i)
		pl.motion_scale = Vector2(scales[i-1], 0)
		pl.motion_mirroring = Vector2(scaled_w, 0)
		
		var sp = Sprite2D.new()
		sp.name = 'Sprite'
		sp.texture = load(base_path + str(i) + '.png')
		sp.scale = Vector2(scale_factor, scale_factor)
		sp.centered = false
		
		bg.add_child(pl)
		pl.owner = bg
		
		pl.add_child(sp)
		sp.owner = bg
		
	var packed = PackedScene.new()
	packed.pack(bg)
	ResourceSaver.save(packed, 'res://scenes/levels/Island4_Background.tscn')
	print('BACKGROUND CREATED')
	quit()

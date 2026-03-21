extends SceneTree

func _init():
	var scene = load('res://scenes/levels/Level_4_5.tscn')
	if not scene: return
	var level = scene.instantiate()
	var viewport = SubViewport.new()
	viewport.size = Vector2(1920, 1080)
	viewport.add_child(level)
	
	var root = get_root()
	root.add_child(viewport)
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img = viewport.get_texture().get_image()
	img.save_png("res://boss_arena_test.png")
	print("SAVED PREVIEW")
	quit()

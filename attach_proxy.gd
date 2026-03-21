extends SceneTree

func _init():
	var scene = load('res://scenes/enemies/Boss.tscn')
	var boss = scene.instantiate()
	
	var proxy = load('res://scripts/enemies/MegaBossHandProxy.gd')
	
	var lh = boss.get_node_or_null('LeftHandArea')
	if lh and proxy:
		lh.set_script(proxy)
		
	var rh = boss.get_node_or_null('RightHandArea')
	if rh and proxy:
		rh.set_script(proxy)
		
	var packed = PackedScene.new()
	packed.pack(boss)
	ResourceSaver.save(packed, 'res://scenes/enemies/Boss.tscn')
	print('PROXY SCRIPTS ATTACHED')
	quit()

extends SceneTree

func _init():
	var boss_scene = load('res://scenes/enemies/Boss.tscn')
	var player_scene = load('res://scenes/player/Player.tscn')
	
	if not boss_scene or not player_scene:
		print("FAILED TO LOAD SCENES")
		quit()
		return
		
	var boss = boss_scene.instantiate()
	var player = player_scene.instantiate()
	
	var root = get_root()
	root.add_child(boss)
	root.add_child(player)
	
	print("Boss LeftHand Area: layer=", boss.get_node('LeftHandArea').collision_layer, " mask=", boss.get_node('LeftHandArea').collision_mask)
	print("Player Body: layer=", player.collision_layer, " mask=", player.collision_mask)
	
	# Move player inside left hand
	boss.global_position = Vector2(500, 500)
	# LeftHand is at (-250, 0) relative to boss, so (250, 500)
	# wait, checking LeftHandArea internal position:
	print("LeftHandArea pos: ", boss.get_node('LeftHandArea').global_position)
	player.global_position = boss.get_node('LeftHandArea').global_position
	
	# Enable hand collision
	var hand_col = boss.get_node('LeftHandArea/CollisionShape2D')
	hand_col.disabled = false
	
	# Enable player attack box
	player.start_attack()
	
	await get_tree().physics_frame
	await get_tree().physics_frame
	
	print("Hand overlaps bodies: ", boss.get_node('LeftHandArea').get_overlapping_bodies())
	print("Hand overlaps areas: ", boss.get_node('LeftHandArea').get_overlapping_areas())
	
	var attack_box = player.get_node_or_null('AttackBox')
	if attack_box:
		print("Player AttackBox overlaps areas: ", attack_box.get_overlapping_areas())
		print("Player AttackBox overlaps bodies: ", attack_box.get_overlapping_bodies())
	
	quit()

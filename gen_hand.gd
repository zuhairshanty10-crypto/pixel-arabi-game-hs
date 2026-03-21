extends SceneTree
func _init():
	var hand = Area2D.new()
	hand.name = 'BossHand'
	hand.set_script(load('res://scripts/enemies/BossHand.gd'))
	hand.collision_layer = 4
	hand.collision_mask = 2
	
	var sprite = Sprite2D.new()
	sprite.name = 'Sprite2D'
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(2.5, 2.5)
	
	# Try Attack1.png frames for hands
	var tex = load('res://assets/island4/enemies/RealBoss/Attack1.png')
	if tex:
		var atlas = AtlasTexture.new()
		atlas.atlas = tex
		# Just capture the fist part from the slam frame 
		atlas.region = Rect2(1040, 110, 110, 140) 
		sprite.texture = atlas
		
	hand.add_child(sprite)
	sprite.owner = hand
	
	var hit_col = CollisionShape2D.new()
	hit_col.name = 'CollisionShape2D'
	var circle = CircleShape2D.new()
	circle.radius = 80.0
	hit_col.shape = circle
	hand.add_child(hit_col)
	hit_col.owner = hand
	
	var packed = PackedScene.new()
	packed.pack(hand)
	ResourceSaver.save(packed, 'res://scenes/enemies/BossHand.tscn')
	print('BossHand RE-CREATED')
	quit()

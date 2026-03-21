extends SceneTree

func _init():
	var boss = Node2D.new()
	boss.name = 'Boss'
	boss.set_script(load('res://scripts/enemies/Boss.gd'))
	boss.add_to_group('enemy')
	boss.add_to_group('boss')
	
	var sprite = AnimatedSprite2D.new()
	sprite.name = 'AnimatedSprite2D'
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(3.0, 3.0)
	# Center the boss up higher so he rests on the horizon
	sprite.position = Vector2(0, -320)
	
	var frames = SpriteFrames.new()
	
	# Load Idle (8 frames)
	var idle_tex = load('res://assets/island4/enemies/RealBoss/Idle.png')
	frames.add_animation('idle')
	if idle_tex:
		for i in range(8):
			var a = AtlasTexture.new()
			a.atlas = idle_tex; a.region = Rect2(i*256, 0, 256, 256)
			frames.add_frame('idle', a)
			
	# Load Attack1 (Right Slam) (6 frames)
	var atk1_tex = load('res://assets/island4/enemies/RealBoss/Attack1.png')
	frames.add_animation('attack1')
	if atk1_tex:
		for i in range(6):
			var a = AtlasTexture.new()
			a.atlas = atk1_tex; a.region = Rect2(i*256, 0, 256, 256)
			frames.add_frame('attack1', a)

	# Load Attack2 (Left Slam) (6 frames)
	var atk2_tex = load('res://assets/island4/enemies/RealBoss/Attack2.png')
	frames.add_animation('attack2')
	if atk2_tex:
		for i in range(6):
			var a = AtlasTexture.new()
			a.atlas = atk2_tex; a.region = Rect2(i*256, 0, 256, 256)
			frames.add_frame('attack2', a)
			
	# Load Hurt (3 frames)
	var hurt_tex = load('res://assets/island4/enemies/RealBoss/Hurt.png')
	frames.add_animation('hurt')
	if hurt_tex:
		for i in range(3):
			var a = AtlasTexture.new()
			a.atlas = hurt_tex; a.region = Rect2(i*256, 0, 256, 256)
			frames.add_frame('hurt', a)
			
	# Load Death (9 frames)
	var death_tex = load('res://assets/island4/enemies/RealBoss/Death.png')
	frames.add_animation('death')
	if death_tex:
		for i in range(9):
			var a = AtlasTexture.new()
			a.atlas = death_tex; a.region = Rect2(i*256, 0, 256, 256)
			frames.add_frame('death', a)
			
	frames.set_animation_loop('attack1', false)
	frames.set_animation_loop('attack2', false)
	frames.set_animation_loop('hurt', false)
	frames.set_animation_loop('death', false)
	
	sprite.sprite_frames = frames
	sprite.animation = 'idle'
	sprite.play('idle')
	boss.add_child(sprite)
	sprite.owner = boss
	
	# Hand Hitboxes (For player to get hurt and to deal damage to Boss)
	# Right Hand
	var right_hand = Area2D.new()
	right_hand.name = 'RightHandArea'
	right_hand.collision_layer = 4
	right_hand.collision_mask = 2
	right_hand.add_to_group('boss_hand')
	right_hand.add_to_group('enemy')
	# Place at bottom right where hand lands
	right_hand.position = Vector2(250, 0)
	
	var rc = CollisionShape2D.new()
	rc.name = 'CollisionShape2D'
	var rshape = CircleShape2D.new()
	rshape.radius = 100.0
	rc.shape = rshape
	right_hand.add_child(rc)
	rc.owner = right_hand
	# Start disabled
	rc.disabled = true
	
	boss.add_child(right_hand)
	right_hand.owner = boss
	
	# Left Hand
	var left_hand = Area2D.new()
	left_hand.name = 'LeftHandArea'
	left_hand.collision_layer = 4
	left_hand.collision_mask = 2
	left_hand.add_to_group('boss_hand')
	left_hand.add_to_group('enemy')
	# Place at bottom left where hand lands
	left_hand.position = Vector2(-250, 0)
	
	var lc = CollisionShape2D.new()
	lc.name = 'CollisionShape2D'
	var lshape = CircleShape2D.new()
	lshape.radius = 100.0
	lc.shape = lshape
	left_hand.add_child(lc)
	lc.owner = left_hand
	# Start disabled
	lc.disabled = true
	
	boss.add_child(left_hand)
	left_hand.owner = boss
	
	var hit_sound = AudioStreamPlayer2D.new()
	hit_sound.name = 'HitSound'
	var punch = load('res://assets/sounds/punch.wav')
	if punch: hit_sound.stream = punch
	boss.add_child(hit_sound)
	hit_sound.owner = boss
	
	var packed = PackedScene.new()
	packed.pack(boss)
	ResourceSaver.save(packed, 'res://scenes/enemies/Boss.tscn')
	print('Mega Boss Scene Reconstructed')
	quit()

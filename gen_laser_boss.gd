extends SceneTree

func _init():
	var scene = load('res://scenes/enemies/Boss.tscn')
	if not scene: return
	var boss = scene.instantiate()
	
	# Add Attack7_body frames to main sprite
	var sprite = boss.get_node('AnimatedSprite2D')
	var frames = sprite.sprite_frames
	if not frames.has_animation('attack7'):
		frames.add_animation('attack7')
		var atk7_tex = load('res://assets/island4/enemies/RealBoss/Attack7_body.png')
		if atk7_tex:
			for i in range(6):
				var a = AtlasTexture.new()
				a.atlas = atk7_tex; a.region = Rect2(i*256, 0, 256, 256)
				frames.add_frame('attack7', a)
		frames.set_animation_loop('attack7', false)

	# Set hand collisions to never be disabled in the scene
	var left_col = boss.get_node_or_null('LeftHandArea/CollisionShape2D')
	if left_col: left_col.disabled = false
	var right_col = boss.get_node_or_null('RightHandArea/CollisionShape2D')
	if right_col: right_col.disabled = false

	# Add Laser Sprite
	if not boss.has_node('LaserSprite'):
		var laser = AnimatedSprite2D.new()
		laser.name = "LaserSprite"
		laser.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		laser.scale = Vector2(3.0, 3.0)
		laser.position = Vector2(0, -320)
		
		var lf = SpriteFrames.new()
		lf.add_animation('shoot')
		var l_tex = load('res://assets/island4/enemies/RealBoss/Attack7_laser.png')
		if l_tex:
			for i in range(8): # 2048 / 256 = 8
				var a = AtlasTexture.new()
				a.atlas = l_tex; a.region = Rect2(i*256, 0, 256, 256)
				lf.add_frame('shoot', a)
		lf.set_animation_loop('shoot', false)
		laser.sprite_frames = lf
		laser.visible = false
		boss.add_child(laser)
		laser.owner = boss

	var packed = PackedScene.new()
	packed.pack(boss)
	ResourceSaver.save(packed, 'res://scenes/enemies/Boss.tscn')
	print("Boss.tscn updated with laser")
	quit()

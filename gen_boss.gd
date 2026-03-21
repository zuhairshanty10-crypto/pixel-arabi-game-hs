extends SceneTree
func _init():
	var boss = Node2D.new()
	boss.name = 'Boss'
	boss.set_script(load('res://scripts/enemies/Boss.gd'))
	boss.add_to_group('enemy')
	
	var head_sprite = AnimatedSprite2D.new()
	head_sprite.name = 'HeadSprite'
	head_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var head_frames = SpriteFrames.new()
	head_frames.add_animation('idle')
	
	var tex = load('res://assets/island4/enemies/RealBoss/Idle.png')
	if tex:
		for i in range(8):
			var atlas = AtlasTexture.new()
			atlas.atlas = tex
			atlas.region = Rect2(i * 256, 0, 256, 256)
			head_frames.add_frame('idle', atlas)
			
	head_sprite.sprite_frames = head_frames
	head_sprite.animation = 'idle'
	head_sprite.play('idle')
	head_sprite.scale = Vector2(2.5, 2.5) # Slight adjust
	head_sprite.position = Vector2(0, -250)
	boss.add_child(head_sprite)
	head_sprite.owner = boss
	
	var hit_sound = AudioStreamPlayer2D.new()
	hit_sound.name = 'HitSound'
	var punch = load('res://assets/sounds/punch.wav')
	if punch: hit_sound.stream = punch
	boss.add_child(hit_sound)
	hit_sound.owner = boss
	
	var packed = PackedScene.new()
	packed.pack(boss)
	ResourceSaver.save(packed, 'res://scenes/enemies/Boss.tscn')
	print('Boss RE-CREATED')
	quit()

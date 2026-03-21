extends SceneTree

func _init():
	var enemy = CharacterBody2D.new()
	enemy.name = 'Enemy'
	
	# Animated Sprite
	var sprite = AnimatedSprite2D.new()
	sprite.name = 'AnimatedSprite2D'
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	var frames = SpriteFrames.new()
	var base = 'res://assets/island4/enemies/1 Skeleton/'
	var frame_size = 42
	
	var anims = {
		'idle': {'file': 'Skeleton_idle.png', 'count': 4, 'speed': 6.0, 'loop': true},
		'walk': {'file': 'Skeleton_walk.png', 'count': 6, 'speed': 8.0, 'loop': true},
		'attack': {'file': 'Skeleton_attack.png', 'count': 4, 'speed': 10.0, 'loop': false},
		'hurt': {'file': 'Skeleton_hurt.png', 'count': 4, 'speed': 10.0, 'loop': false},
		'death': {'file': 'Skeleton_death.png', 'count': 4, 'speed': 8.0, 'loop': false}
	}
	
	# Remove default animation
	if frames.has_animation('default'):
		frames.remove_animation('default')
	
	for anim_name in anims:
		var info = anims[anim_name]
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, info['loop'])
		frames.set_animation_speed(anim_name, info['speed'])
		var tex = load(base + info['file'])
		if tex:
			for i in range(info['count']):
				var atlas = AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(i * frame_size, 0, frame_size, frame_size)
				frames.add_frame(anim_name, atlas)
	
	sprite.sprite_frames = frames
	sprite.animation = 'idle'
	sprite.play('idle')
	
	enemy.add_child(sprite)
	sprite.owner = enemy
	
	# Collision Shape
	var col = CollisionShape2D.new()
	col.name = 'CollisionShape2D'
	var rect = RectangleShape2D.new()
	rect.size = Vector2(20, 36)
	col.shape = rect
	col.position = Vector2(0, -18)
	enemy.add_child(col)
	col.owner = enemy
	
	# Offset sprite so feet align with collision bottom
	sprite.offset = Vector2(0, -21)
	
	# Script
	var scr = load('res://scripts/enemies/Enemy.gd')
	enemy.script = scr
	
	# Save
	var packed = PackedScene.new()
	packed.pack(enemy)
	ResourceSaver.save(packed, 'res://scenes/enemies/Enemy.tscn')
	print('ENEMY SCENE CREATED')
	quit()

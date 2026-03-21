extends SceneTree

func _init():
	var enemies = {
		'Beholder': {'path': '4 Beholder/Beholder', 'walk_frames': 4, 'death_frames': 4},
		'Husky': {'path': '5 Husky/Husky', 'walk_frames': 6, 'death_frames': 4},
		'DarkGoblin': {'path': '6 Dark_Goblin/DarkGoblin', 'walk_frames': 6, 'death_frames': 4}
	}
	
	var base_path = 'res://assets/island4/enemies/'
	var frame_size = 42
	var script_res = load('res://scripts/enemies/Enemy.gd')
	
	for name in enemies:
		var info = enemies[name]
		var enemy = CharacterBody2D.new()
		enemy.name = name
		enemy.script = script_res
		
		var sprite = AnimatedSprite2D.new()
		sprite.name = 'AnimatedSprite2D'
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.offset = Vector2(0, -21)
		
		var frames = SpriteFrames.new()
		if frames.has_animation('default'):
			frames.remove_animation('default')
		
		var anims = {
			'idle': {'count': 4, 'speed': 6.0, 'loop': true},
			'walk': {'count': info['walk_frames'], 'speed': 8.0, 'loop': true},
			'attack': {'count': 4, 'speed': 10.0, 'loop': false},
			'hurt': {'count': 4, 'speed': 10.0, 'loop': false},
			'death': {'count': info['death_frames'], 'speed': 8.0, 'loop': false}
		}
		
		for anim_name in anims:
			var anim_info = anims[anim_name]
			frames.add_animation(anim_name)
			frames.set_animation_loop(anim_name, anim_info['loop'])
			frames.set_animation_speed(anim_name, anim_info['speed'])
			var tex = load(base_path + info['path'] + '_' + anim_name + '.png')
			if tex:
				for i in range(anim_info['count']):
					var atlas = AtlasTexture.new()
					atlas.atlas = tex
					atlas.region = Rect2(i * frame_size, 0, frame_size, frame_size)
					frames.add_frame(anim_name, atlas)
		
		sprite.sprite_frames = frames
		sprite.animation = 'idle'
		enemy.add_child(sprite)
		sprite.owner = enemy
		
		var col = CollisionShape2D.new()
		col.name = 'CollisionShape2D'
		var rect = RectangleShape2D.new()
		rect.size = Vector2(20, 36)
		col.shape = rect
		col.position = Vector2(0, -18)
		enemy.add_child(col)
		col.owner = enemy
		
		var packed = PackedScene.new()
		packed.pack(enemy)
		ResourceSaver.save(packed, 'res://scenes/enemies/' + name + '.tscn')
		print(name + ' CREATED')
	
	quit()

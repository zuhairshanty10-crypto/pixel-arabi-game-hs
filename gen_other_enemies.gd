extends SceneTree

func _init():
	var enemy_types = {
		'Zombie': '2 Zombie/Zombie',
		'Hellhound': '3 Hellhound/Hellhound'
	}
	
	var anim_counts = {
		'idle': 4,
		'walk': 6,
		'attack': 4,
		'hurt': 4,
		'death': 4
	}
	
	# Hellhound death is 6 frames (252/42)
	var hellhound_anims = anim_counts.duplicate()
	hellhound_anims['death'] = 6
	
	var base_path = 'res://assets/island4/enemies/'
	var frame_size = 42
	var script_res = load('res://scripts/enemies/Enemy.gd')
	
	for name in enemy_types:
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
			
		var sub_path = enemy_types[name]
		var current_anim_counts = anim_counts if name == 'Zombie' else hellhound_anims
		
		for anim in current_anim_counts:
			frames.add_animation(anim)
			frames.set_animation_loop(anim, anim == 'idle' or anim == 'walk')
			frames.set_animation_speed(anim, 8.0)
			
			var tex_path = base_path + sub_path + '_' + anim + '.png'
			var tex = load(tex_path)
			if tex:
				for i in range(current_anim_counts[anim]):
					var atlas = AtlasTexture.new()
					atlas.atlas = tex
					atlas.region = Rect2(i * frame_size, 0, frame_size, frame_size)
					frames.add_frame(anim, atlas)
		
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
		print(name + ' SCENE CREATED')
		
	quit()

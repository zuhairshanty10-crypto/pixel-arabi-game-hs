extends SceneTree

func _init():
	# Create the DarkKnightBoss scene programmatically
	var tscn = ""
	
	# First, gather all resource info
	var base = "res://assets/island4/enemies/DarkKnight/"
	var anims = {
		"idle": {"file": "Idle.png", "frames": 8, "speed": 5.0, "loop": true},
		"run": {"file": "Run.png", "frames": 8, "speed": 10.0, "loop": true},
		"walk": {"file": "Walk.png", "frames": 8, "speed": 8.0, "loop": true},
		"attack1": {"file": "Attack.png", "frames": 8, "speed": 8.0, "loop": false},
		"attack2": {"file": "Attack2.png", "frames": 8, "speed": 8.0, "loop": false},
		"attack3": {"file": "Attack3.png", "frames": 8, "speed": 8.0, "loop": false},
		"hurt": {"file": "Hurt.png", "frames": 2, "speed": 5.0, "loop": false},
		"death": {"file": "Death.png", "frames": 8, "speed": 5.0, "loop": false},
		"special": {"file": "Special.png", "frames": 8, "speed": 8.0, "loop": false},
		"jump": {"file": "Jump.png", "frames": 8, "speed": 8.0, "loop": false},
	}
	
	# Build the tscn content
	var lines = []
	
	# Count resources needed
	var ext_count = 3  # script, audio placeholder
	var sub_count = 0
	
	# Count all atlas textures + sprite frames
	var total_atlas = 0
	for anim_name in anims:
		total_atlas += anims[anim_name]["frames"]
	sub_count = total_atlas + 2  # +1 for SpriteFrames, +1 for body collision, +1 for sword collision
	
	# Header
	var load_steps = ext_count + sub_count + 5
	lines.append('[gd_scene load_steps=' + str(load_steps) + ' format=4]')
	lines.append('')
	
	# External resources
	lines.append('[ext_resource type="Script" path="res://scripts/enemies/DarkKnightBoss.gd" id="1_script"]')
	lines.append('[ext_resource type="AudioStream" path="res://assets/sounds/punch.wav" id="2_sound"]')
	
	# External textures
	var tex_id = 1
	var tex_ids = {}
	for anim_name in anims:
		var fname = anims[anim_name]["file"]
		var res_id = "tex_" + str(tex_id)
		tex_ids[anim_name] = res_id
		lines.append('[ext_resource type="Texture2D" path="' + base + fname + '" id="' + res_id + '"]')
		tex_id += 1
	
	lines.append('')
	
	# Sub resources - Atlas textures
	var atlas_ids = {}  # anim_name -> [list of atlas ids]
	var sub_id = 1
	for anim_name in anims:
		var frame_count = anims[anim_name]["frames"]
		var frame_w = 256
		var frame_h = 256
		atlas_ids[anim_name] = []
		for i in range(frame_count):
			var aid = "atlas_" + str(sub_id)
			atlas_ids[anim_name].append(aid)
			lines.append('[sub_resource type="AtlasTexture" id="' + aid + '"]')
			lines.append('atlas = ExtResource("' + tex_ids[anim_name] + '")')
			lines.append('region = Rect2(' + str(i * frame_w) + ', 0, ' + str(frame_w) + ', ' + str(frame_h) + ')')
			lines.append('')
			sub_id += 1
	
	# SpriteFrames resource
	lines.append('[sub_resource type="SpriteFrames" id="sprite_frames"]')
	lines.append('animations = [{')
	
	var anim_keys = anims.keys()
	for idx in range(anim_keys.size()):
		var anim_name = anim_keys[idx]
		var info = anims[anim_name]
		if idx > 0:
			lines.append('}, {')
		lines.append('"frames": [{')
		var ids = atlas_ids[anim_name]
		for f in range(ids.size()):
			if f > 0:
				lines.append('}, {')
			lines.append('"duration": 1.0,')
			lines.append('"texture": SubResource("' + ids[f] + '")')
		lines.append('}],')
		lines.append('"loop": ' + ('true' if info["loop"] else 'false') + ',')
		lines.append('"name": &"' + anim_name + '",')
		lines.append('"speed": ' + str(info["speed"]))
	
	lines.append('}]')
	lines.append('')
	
	# Body collision shape
	lines.append('[sub_resource type="CapsuleShape2D" id="body_shape"]')
	lines.append('radius = 30.0')
	lines.append('height = 80.0')
	lines.append('')
	
	# Sword collision shape
	lines.append('[sub_resource type="RectangleShape2D" id="sword_shape"]')
	lines.append('size = Vector2(80, 60)')
	lines.append('')
	
	# === NODES ===
	lines.append('[node name="DarkKnightBoss" type="CharacterBody2D"]')
	lines.append('collision_layer = 4')
	lines.append('collision_mask = 1')
	lines.append('script = ExtResource("1_script")')
	lines.append('')
	
	lines.append('[node name="AnimatedSprite2D" type="AnimatedSprite2D" parent="."]')
	lines.append('texture_filter = 1')
	lines.append('position = Vector2(0, -100)')
	lines.append('scale = Vector2(3, 3)')
	lines.append('sprite_frames = SubResource("sprite_frames")')
	lines.append('animation = &"idle"')
	lines.append('')
	
	lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="."]')
	lines.append('position = Vector2(0, -40)')
	lines.append('shape = SubResource("body_shape")')
	lines.append('')
	
	lines.append('[node name="SwordHitbox" type="Area2D" parent="."]')
	lines.append('position = Vector2(-80, -50)')
	lines.append('collision_layer = 0')
	lines.append('collision_mask = 2')
	lines.append('')
	
	lines.append('[node name="CollisionShape2D" type="CollisionShape2D" parent="SwordHitbox"]')
	lines.append('shape = SubResource("sword_shape")')
	lines.append('disabled = true')
	lines.append('')
	
	lines.append('[node name="HitSound" type="AudioStreamPlayer2D" parent="."]')
	lines.append('stream = ExtResource("2_sound")')
	lines.append('')
	
	# Write file
	var file = FileAccess.open("res://scenes/enemies/DarkKnightBoss.tscn", FileAccess.WRITE)
	for line in lines:
		file.store_line(line)
	file.close()
	print("DarkKnightBoss.tscn created successfully!")
	quit()

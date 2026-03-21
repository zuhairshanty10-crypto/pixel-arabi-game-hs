extends SceneTree

func _init():
	var lines = []
	lines.append('[gd_scene load_steps=3 format=4]')
	lines.append('')
	lines.append('[ext_resource type="Script" path="res://scripts/ui/TouchControls.gd" id="1_script"]')
	lines.append('[ext_resource type="Texture2D" path="res://assets/ui/premium/Button_off.png" id="2_tex"]')
	lines.append('')
	lines.append('[node name="TouchControls" type="CanvasLayer"]')
	lines.append('layer = 100')
	lines.append('script = ExtResource("1_script")')
	lines.append('')
	
	var actions = ["move_left", "move_right", "jump", "dash", "attack"]
	for act in actions:
		lines.append('[node name="' + act + '" type="TouchScreenButton" parent="."]')
		lines.append('texture_normal = ExtResource("2_tex")')
		lines.append('action = "' + act + '"')
		lines.append('visibility_mode = 1') # SHOW_TOUCHSCREEN_ONLY
		lines.append('')
		
		# Add a label so players know what button is what
		lines.append('[node name="Label" type="Label" parent="' + act + '"]')
		lines.append('anchors_preset = 15')
		lines.append('anchor_right = 1.0')
		lines.append('anchor_bottom = 1.0')
		lines.append('grow_horizontal = 2')
		lines.append('grow_vertical = 2')
		lines.append('text = "' + act.replace("_", " ").to_upper() + '"')
		lines.append('horizontal_alignment = 1')
		lines.append('vertical_alignment = 1')
		lines.append('')

	var file = FileAccess.open("res://scenes/ui/TouchControls.tscn", FileAccess.WRITE)
	for line in lines:
		file.store_line(line)
	file.close()
	print("TouchControls.tscn created successfully!")
	quit()

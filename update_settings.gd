extends SceneTree

func _init():
	var packed = load("res://scenes/ui/SettingsScreen.tscn")
	var scene = packed.instantiate()
	
	var vbox = scene.get_node("CenterPanel/VBox")
	var lang_idx = scene.get_node("CenterPanel/VBox/LanguageLabel").get_index()
	
	var controls_btn = Button.new()
	controls_btn.name = "ControlsButton"
	controls_btn.text = "Controls"
	controls_btn.add_theme_font_size_override("font_size", 26)
	vbox.add_child(controls_btn)
	vbox.move_child(controls_btn, lang_idx)
	
	# Add a spacer
	var spc = Control.new()
	spc.name = "ControlsSpacer"
	spc.custom_minimum_size = Vector2(0, 10)
	vbox.add_child(spc)
	vbox.move_child(spc, lang_idx + 1)
	
	# We also need to increase CenterPanel size just in case, or let it resize.
	var cp = scene.get_node("CenterPanel")
	cp.offset_top -= 40
	cp.offset_bottom += 40
	
	var pack = PackedScene.new()
	pack.pack(scene)
	ResourceSaver.save(pack, "res://scenes/ui/SettingsScreen.tscn")
	print("SettingsScreen updated with Controls button!")
	quit()

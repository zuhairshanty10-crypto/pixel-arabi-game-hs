extends Control

@onready var title = $Title
@onready var buttons_container = $GridContainer
@onready var back_button = $BackButton
@onready var template_bg = $GridContainer/LevelButtonTemplate
@onready var background = $Background

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	
	var island_id = GameManager.current_island
	
	if Localization:
		var is_ar = Localization.current_language == "ar"
		title.text = Localization.get_text("island_" + str(island_id))
		back_button.text = Localization.get_text("back") if Localization.get_text("back") != "back" else ("رجوع للمركز" if is_ar else "Back to Islands")
		
		var labels = [title, back_button]
		for l in labels:
			if is_ar:
				var arabic_font = load("res://assets/fonts/ArabicTypesetting.ttf")
				l.add_theme_font_override("font", arabic_font)
				if not l.has_meta("orig_size"):
					var c_size = 36
					if l.has_theme_font_size_override("font_size"): c_size = l.get_theme_font_size("font_size")
					l.set_meta("orig_size", c_size)
				l.add_theme_font_size_override("font_size", l.get_meta("orig_size") + 16)
			else:
				l.remove_theme_font_override("font")
				if l.has_meta("orig_size"):
					l.add_theme_font_size_override("font_size", l.get_meta("orig_size"))
	else:
		title.text = "Island " + str(island_id)
		
	if background:
		var tex = null
		var base_path = "res://assets/ui/islands/island" + str(island_id)
		if ResourceLoader.exists(base_path + ".jpg"): tex = load(base_path + ".jpg")
		elif ResourceLoader.exists(base_path + ".png"): tex = load(base_path + ".png")
		elif ResourceLoader.exists(base_path + ".webp"): tex = load(base_path + ".webp")
		
		if tex is Texture2D:
			background.texture = tex
			background.modulate = Color(1, 1, 1, 1) # Remove the blue tint
			background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED # Value 6 in enum
	
	template_bg.hide()
	
	# Generate 5 levels for the current island
	for i in range(1, 6):
		var bg = template_bg.duplicate()
		bg.show()
		buttons_container.add_child(bg)
		
		var btn = bg as Button
		var label = bg.get_node("Label") as Label
		var lock_icon = bg.get_node("LockIcon") as TextureRect
		
		label.text = str(i)
		
		if GameManager.is_level_unlocked(GameManager.current_island, i):
			btn.disabled = false
			lock_icon.hide()
			label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			btn.pressed.connect(func(): _on_level_selected(i))
		else:
			btn.disabled = true
			lock_icon.show()
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))

	# Establish default focus for Gamepad UI navigation
	var found_focus = false
	for p in buttons_container.get_children():
		var b = p.get_node_or_null("Button")
		if b is Button and not b.disabled and b.visible:
			b.grab_focus()
			found_focus = true
			break
	if not found_focus:
		back_button.grab_focus()

func _on_level_selected(level: int):
	var island = GameManager.current_island
	var level_path: String
	if island == 1:
		level_path = "res://scenes/levels/Level_%02d.tscn" % level
	else:
		level_path = "res://scenes/levels/Level_%d_%d.tscn" % [island, level]
	get_tree().change_scene_to_file(level_path)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/IslandSelection.tscn")

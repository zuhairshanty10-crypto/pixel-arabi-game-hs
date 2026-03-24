extends Control

@onready var title = $Title
@onready var buttons_container = $ScrollContainer/HBoxContainer
@onready var back_button = $BackButton
@onready var template_bg = $ScrollContainer/HBoxContainer/IslandButtonTemplate

var arabic_font: Font = null

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	
	arabic_font = load("res://assets/fonts/ArabicTypesetting.ttf")
	
	if Localization:
		var is_ar = Localization.current_language == "ar"
		title.text = "اختيار الجزيرة" if is_ar else "Select Island"
		back_button.text = Localization.get_text("back") if Localization.get_text("back") != "back" else ("رجوع للمركز" if is_ar else "Back to Menu")
		
		# Apply scaled font if Arabic
		var labels = [title, back_button]
		for l in labels:
			if is_ar and arabic_font:
				l.add_theme_font_override("font", arabic_font)
				if not l.has_meta("orig_size"):
					var c_size = 28
					if l.has_theme_font_size_override("font_size"): c_size = l.get_theme_font_size("font_size")
					l.set_meta("orig_size", c_size)
				l.add_theme_font_size_override("font_size", l.get_meta("orig_size") + 16)
			else:
				l.remove_theme_font_override("font")
				if l.has_meta("orig_size"):
					l.add_theme_font_size_override("font_size", l.get_meta("orig_size"))
	
	# Hide the template
	template_bg.hide()
	
	# Generate 5 islands
	for i in range(1, 6):
		var bg = template_bg.duplicate()
		bg.show()
		buttons_container.add_child(bg)
		
		var btn = bg.get_node("Button") as Button
		var label = bg.get_node("Label") as Label
		var lock_icon = bg.get_node("LockIcon") as TextureRect
		
		if Localization:
			label.text = Localization.get_text("island_" + str(i))
			if Localization.current_language == "ar" and arabic_font:
				label.add_theme_font_override("font", arabic_font)
				if not label.has_meta("orig_size"):
					var c_size = 32
					if label.has_theme_font_size_override("font_size"): c_size = label.get_theme_font_size("font_size")
					label.set_meta("orig_size", c_size)
				label.add_theme_font_size_override("font_size", label.get_meta("orig_size") + 14)
			else:
				label.remove_theme_font_override("font")
				if label.has_meta("orig_size"):
					label.add_theme_font_size_override("font_size", label.get_meta("orig_size"))
		else:
			label.text = "Island " + str(i)
		
		var thumbnail = bg.get_node_or_null("Thumbnail") as TextureRect
		if thumbnail:
			var tex = null
			var base_path = "res://assets/ui/islands/island" + str(i)
			if ResourceLoader.exists(base_path + ".jpg"): tex = load(base_path + ".jpg")
			elif ResourceLoader.exists(base_path + ".png"): tex = load(base_path + ".png")
			elif ResourceLoader.exists(base_path + ".webp"): tex = load(base_path + ".webp")
			
			if tex is Texture2D:
				thumbnail.texture = tex
		
		if GameManager.is_island_unlocked(i):
			btn.disabled = false
			lock_icon.hide()
			label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
			if thumbnail: thumbnail.modulate = Color(1, 1, 1, 1) # Full brightness
			btn.pressed.connect(func(): _on_island_selected(i))
		else:
			btn.disabled = true
			lock_icon.show()
			label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5, 1))
			if thumbnail: thumbnail.modulate = Color(0.6, 0.6, 0.6, 1) # Darken slightly for lock
			
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

func _on_island_selected(island: int):
	GameManager.current_island = island
	get_tree().change_scene_to_file("res://scenes/levels/LevelSelection.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

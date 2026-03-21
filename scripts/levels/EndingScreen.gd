extends CanvasLayer

## Level 5-5: The Ending / Congratulations Screen

func _ready() -> void:
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(vbox)
	
	# Background
	var bg = ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.05, 0.02, 0.1, 1.0)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	bg.z_index = -1
	
	# Determine language
	var lang = "en"
	if Localization:
		lang = Localization.current_language
	
	var main_text = ""
	var sub_text = ""
	
	if lang == "ar":
		main_text = "مبروك! إذا وصلت لهون أنت بتحتاج طبيب نفسي"
		sub_text = "إذا حسيت نفسك ما اكتفيت انتظر المراحل القادمة\nفي التحديث القادم قريباً جداً"
	else:
		main_text = "Congratulations! If you made it here,\nyou probably need a therapist."
		sub_text = "If you feel like you haven't had enough,\nstay tuned for more levels in the next update.\nComing very soon!"
	
	# Crown emoji / icon
	var crown = Label.new()
	crown.text = "👑"
	crown.add_theme_font_size_override("font_size", 100)
	crown.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	crown.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(crown)
	
	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 30)
	vbox.add_child(spacer1)
	
	# Main congratulations text
	var main_label = Label.new()
	main_label.text = main_text
	main_label.add_theme_font_size_override("font_size", 48)
	main_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
	main_label.add_theme_color_override("font_outline_color", Color.BLACK)
	main_label.add_theme_constant_override("outline_size", 6)
	main_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	main_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(main_label)
	
	# Spacer
	var spacer2 = Control.new()
	spacer2.custom_minimum_size = Vector2(0, 40)
	vbox.add_child(spacer2)
	
	# Sub text
	var sub_label = Label.new()
	sub_label.text = sub_text
	sub_label.add_theme_font_size_override("font_size", 30)
	sub_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.9))
	sub_label.add_theme_color_override("font_outline_color", Color.BLACK)
	sub_label.add_theme_constant_override("outline_size", 4)
	sub_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	sub_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(sub_label)
	
	# Spacer
	var spacer3 = Control.new()
	spacer3.custom_minimum_size = Vector2(0, 60)
	vbox.add_child(spacer3)
	
	# Main Menu button
	var menu_text = "العودة للقائمة الرئيسية" if lang == "ar" else "Back to Main Menu"
	var btn = Button.new()
	btn.text = menu_text
	btn.add_theme_font_size_override("font_size", 28)
	btn.custom_minimum_size = Vector2(400, 60)
	btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	vbox.add_child(btn)
	
	# Animate text appearance
	vbox.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(vbox, "modulate:a", 1.0, 2.0)

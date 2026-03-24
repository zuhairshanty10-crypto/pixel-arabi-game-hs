extends Control

@onready var keybinds_container = $CenterPanel/VBox/ScrollContainer/KeybindsContainer
@onready var rebind_overlay = $RebindOverlay
@onready var back_button = $CenterPanel/VBox/BackButton
@onready var touch_layout_btn = $CenterPanel/VBox/TouchLayoutBtn
@onready var title = $CenterPanel/VBox/Title

var action_to_rebind: String = ""
var rebind_type: String = ""
var is_overlay: bool = false  # Set to true when spawned from Pause Menu
var origin_focus_node: Control = null

func _ready() -> void:
	set_process_input(false)
	origin_focus_node = get_viewport().gui_get_focus_owner()
	
	back_button.pressed.connect(func(): 
		if is_overlay:
			if origin_focus_node:
				origin_focus_node.grab_focus()
			queue_free()
		else:
			get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn")
	)
	
	touch_layout_btn.pressed.connect(_on_touch_layout_pressed)
	
	if _is_mobile():
		touch_layout_btn.visible = true
	else:
		touch_layout_btn.visible = false
		
	keybinds_container.get_parent().visible = true
	_populate_keybinds()
	
	_update_language()
	
	back_button.grab_focus()

func _is_mobile() -> bool:
	return OS.get_name() in ["Android", "iOS", "Web"] or ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false)

func _update_language() -> void:
	if not Localization: return
	var lang = Localization.current_language
	title.text = Localization.get_text("controls_title") if Localization.get_text("controls_title") != "controls_title" else ("التحكم" if lang == "ar" else "Controls")
	back_button.text = Localization.get_text("back") if Localization.get_text("back") != "back" else ("رجوع" if lang == "ar" else "Back")
	touch_layout_btn.text = "تخصيص أزرار الشاشة" if lang == "ar" else "Customize Touch Layout"

func get_joy_button_string(idx: int) -> String:
	match idx:
		JOY_BUTTON_A: return "A / Cross"
		JOY_BUTTON_B: return "B / Circle"
		JOY_BUTTON_X: return "X / Square"
		JOY_BUTTON_Y: return "Y / Triangle"
		JOY_BUTTON_BACK: return "Select/Back"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_LEFT_STICK: return "L3"
		JOY_BUTTON_RIGHT_STICK: return "R3"
		JOY_BUTTON_LEFT_SHOULDER: return "LB / L1"
		JOY_BUTTON_RIGHT_SHOULDER: return "RB / R1"
		JOY_BUTTON_DPAD_UP: return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
	return "Joy " + str(idx)

func _get_action_label(action: String, lang: String) -> String:
	if lang == "ar":
		match action:
			"move_left": return "يسار"
			"move_right": return "يمين"
			"move_up": return "أعلى"
			"move_down": return "أسفل"
			"jump": return "قفز"
			"dash": return "اندفاع"
			"roll": return "دحرجة"
			"attack": return "هجوم"
			"shield": return "دفاع"
			"ui_cancel": return "إيقاف"
	return InputManager.customizable_actions[action]["name"]

func _get_key_display(keycode: int) -> String:
	if keycode < 0:
		var m_name = "Mouse " + str(-keycode)
		if -keycode == MOUSE_BUTTON_LEFT: m_name = "Left Click"
		elif -keycode == MOUSE_BUTTON_RIGHT: m_name = "Right Click"
		elif -keycode == MOUSE_BUTTON_MIDDLE: m_name = "Mid Click"
		return m_name
	return OS.get_keycode_string(keycode)

func _create_section_header(text: String) -> Label:
	var header = Label.new()
	header.text = text
	header.add_theme_font_size_override("font_size", 28)
	header.add_theme_color_override("font_color", Color(0.4, 0.85, 1.0, 1.0))
	header.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.6))
	header.add_theme_constant_override("shadow_offset_x", 1)
	header.add_theme_constant_override("shadow_offset_y", 2)
	header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return header

func _create_styled_btn(text: String) -> Button:
	var btn = Button.new()
	btn.text = text
	btn.add_theme_font_size_override("font_size", 22)
	btn.custom_minimum_size = Vector2(180, 40)
	# Use StyleBoxFlat for consistency
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.08, 0.06, 0.18, 0.7)
	normal_sb.set_border_width_all(1)
	normal_sb.border_color = Color(0.5, 0.4, 0.85, 0.5)
	normal_sb.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("normal", normal_sb)
	var hover_sb = StyleBoxFlat.new()
	hover_sb.bg_color = Color(0.12, 0.08, 0.25, 0.85)
	hover_sb.set_border_width_all(2)
	hover_sb.border_color = Color(0.4, 0.85, 1.0, 0.9)
	hover_sb.set_corner_radius_all(8)
	btn.add_theme_stylebox_override("hover", hover_sb)
	return btn

func _create_separator() -> HSeparator:
	var sep = HSeparator.new()
	sep.add_theme_constant_override("separation", 6)
	sep.modulate = Color(0.5, 0.4, 0.8, 0.3)
	return sep

func _populate_keybinds() -> void:
	for child in keybinds_container.get_children():
		child.queue_free()
		
	if not InputManager: return
	
	var lang = "en"
	if Localization: lang = Localization.current_language
	
	var actions = InputManager.customizable_actions
	var on_mobile = _is_mobile()
	
	# =================== KEYBOARD SECTION ===================
	if not on_mobile:
		var kb_header_text = "⌨️  لوحة المفاتيح" if lang == "ar" else "⌨️  Keyboard / Mouse"
		keybinds_container.add_child(_create_section_header(kb_header_text))
		keybinds_container.add_child(_create_separator())
		
		for action in actions:
			var hbox = HBoxContainer.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			
			var label = Label.new()
			label.text = _get_action_label(action, lang)
			label.add_theme_font_size_override("font_size", 22)
			label.add_theme_color_override("font_color", Color(0.85, 0.8, 1.0, 1.0))
			label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			hbox.add_child(label)
			
			var keycode = InputManager.get_action_keycode(action)
			var key_btn = _create_styled_btn(_get_key_display(keycode))
			key_btn.pressed.connect(_on_rebind_pressed.bind(action, "keyboard"))
			hbox.add_child(key_btn)
			
			keybinds_container.add_child(hbox)
		
		# Spacer between sections
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 14)
		keybinds_container.add_child(spacer)
	
	# =================== GAMEPAD SECTION ===================
	var gp_header_text = "🎮  وحدة التحكم" if lang == "ar" else "🎮  Gamepad"
	keybinds_container.add_child(_create_section_header(gp_header_text))
	keybinds_container.add_child(_create_separator())
	
	for action in actions:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label = Label.new()
		label.text = _get_action_label(action, lang)
		label.add_theme_font_size_override("font_size", 22)
		label.add_theme_color_override("font_color", Color(0.85, 0.8, 1.0, 1.0))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		var joycode = InputManager.get_action_joycode(action)
		var joy_btn = _create_styled_btn(get_joy_button_string(joycode))
		joy_btn.pressed.connect(_on_rebind_pressed.bind(action, "gamepad"))
		hbox.add_child(joy_btn)
		
		keybinds_container.add_child(hbox)

func _on_rebind_pressed(action: String, type: String) -> void:
	action_to_rebind = action
	rebind_type = type
	rebind_overlay.show()
	
	var lang = "en"
	if Localization: lang = Localization.current_language
	
	if type == "keyboard":
		rebind_overlay.get_node("Label").text = "اضغط على أي زر بالكيبورد أو الماوس..." if lang == "ar" else "Press any key or mouse button..."
	else:
		rebind_overlay.get_node("Label").text = "اضغط على أي زر بالكنترولر..." if lang == "ar" else "Press any gamepad button..."
		
	set_process_input(true)
	rebind_overlay.grab_focus()

func _input(event: InputEvent) -> void:
	if not rebind_overlay.visible:
		return
		
	if event is InputEventKey and event.is_pressed() and rebind_type == "keyboard":
		if event.keycode != KEY_ESCAPE:
			InputManager.update_keybinding(action_to_rebind, event.physical_keycode)
			
		_close_rebind()
		get_viewport().set_input_as_handled()
		
	elif event is InputEventMouseButton and event.is_pressed() and rebind_type == "keyboard":
		if event.button_index in [MOUSE_BUTTON_LEFT, MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_MIDDLE, MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			InputManager.update_keybinding(action_to_rebind, -event.button_index)
			
		_close_rebind()
		get_viewport().set_input_as_handled()
		
	elif event is InputEventJoypadButton and event.is_pressed() and rebind_type == "gamepad":
		InputManager.update_joybinding(action_to_rebind, event.button_index)
		
		_close_rebind()
		get_viewport().set_input_as_handled()

func _close_rebind() -> void:
	rebind_overlay.hide()
	set_process_input(false)
	_populate_keybinds()

func _on_touch_layout_pressed() -> void:
	var editor_scene = load("res://scenes/ui/TouchLayoutEditor.tscn")
	if editor_scene:
		get_tree().root.add_child(editor_scene.instantiate())

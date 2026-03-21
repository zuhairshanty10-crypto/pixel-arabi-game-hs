extends Control

@onready var keybinds_container = $CenterPanel/VBox/ScrollContainer/KeybindsContainer
@onready var rebind_overlay = $RebindOverlay
@onready var back_button = $CenterPanel/VBox/BackBG/BackButton
@onready var touch_layout_btn = $CenterPanel/VBox/TouchLayoutBtn
@onready var title = $CenterPanel/VBox/Title

var action_to_rebind: String = ""
var rebind_type: String = ""

func _ready() -> void:
	set_process_unhandled_input(false)
	
	back_button.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn"))
	touch_layout_btn.pressed.connect(_on_touch_layout_pressed)
	
	if _is_mobile():
		touch_layout_btn.visible = true
	else:
		touch_layout_btn.visible = false
		
	keybinds_container.get_parent().visible = true
	_populate_keybinds()
	
	_update_language()

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

func _populate_keybinds() -> void:
	for child in keybinds_container.get_children():
		child.queue_free()
		
	if not InputManager: return
	
	var lang = "en"
	if Localization: lang = Localization.current_language
	
	var actions = InputManager.customizable_actions
	var on_mobile = _is_mobile()
	
	for action in actions:
		var hbox = HBoxContainer.new()
		hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var label = Label.new()
		label.text = actions[action]["name"]
		if lang == "ar":
			match action:
				"move_left": label.text = "يسار"
				"move_right": label.text = "يمين"
				"move_up": label.text = "أعلى"
				"move_down": label.text = "أسفل"
				"jump": label.text = "قفز"
				"dash": label.text = "اندفاع"
				"roll": label.text = "دحرجة"
				"attack": label.text = "هجوم"
				"shield": label.text = "دفاع"
				"ui_cancel": label.text = "توقيف"
				
		label.add_theme_font_size_override("font_size", 24)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		hbox.add_child(label)
		
		# Keyboard Button (Hidden on Mobile)
		if not on_mobile:
			var key_btn = Button.new()
			var keycode = InputManager.get_action_keycode(action)
			key_btn.text = "KB: " + OS.get_keycode_string(keycode)
			key_btn.add_theme_font_size_override("font_size", 24)
			key_btn.custom_minimum_size = Vector2(160, 40)
			key_btn.pressed.connect(_on_rebind_pressed.bind(action, "keyboard"))
			hbox.add_child(key_btn)
			
		# Joypad Button
		var joy_btn = Button.new()
		var joycode = InputManager.get_action_joycode(action)
		joy_btn.text = "🎮: " + get_joy_button_string(joycode)
		joy_btn.add_theme_font_size_override("font_size", 24)
		joy_btn.custom_minimum_size = Vector2(200, 40)
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
		rebind_overlay.get_node("Label").text = "اضغط على أي زر بالكيبورد..." if lang == "ar" else "Press any key..."
	else:
		rebind_overlay.get_node("Label").text = "اضغط على أي زر بالكنترولر..." if lang == "ar" else "Press any gamepad button..."
		
	set_process_unhandled_input(true)
	rebind_overlay.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if not rebind_overlay.visible:
		return
		
	if event is InputEventKey and event.is_pressed() and rebind_type == "keyboard":
		if event.keycode != KEY_ESCAPE:
			InputManager.update_keybinding(action_to_rebind, event.physical_keycode)
			
		_close_rebind()
		get_viewport().set_input_as_handled()
		
	elif event is InputEventJoypadButton and event.is_pressed() and rebind_type == "gamepad":
		InputManager.update_joybinding(action_to_rebind, event.button_index)
		
		_close_rebind()
		get_viewport().set_input_as_handled()

func _close_rebind() -> void:
	rebind_overlay.hide()
	set_process_unhandled_input(false)
	_populate_keybinds()

func _on_touch_layout_pressed() -> void:
	var editor_scene = load("res://scenes/ui/TouchLayoutEditor.tscn")
	if editor_scene:
		get_tree().root.add_child(editor_scene.instantiate())

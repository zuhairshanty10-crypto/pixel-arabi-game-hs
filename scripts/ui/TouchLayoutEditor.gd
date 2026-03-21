extends CanvasLayer

@onready var buttons_parent = $Buttons

var dragging_button: Control = null
var drag_offset = Vector2.ZERO

var selected_button: Control = null
var scale_slider: HSlider
var scale_label: Label

func _ready() -> void:
	_build_scale_ui()
	
	# Populate editor buttons based on InputManager's touch layouts
	for action in InputManager.default_touch_layout:
		var btn = TextureRect.new()
		btn.name = action
		var act_name = InputManager.customizable_actions[action]["name"] if InputManager.customizable_actions.has(action) else action
		var is_ar = Localization and Localization.current_language == "ar"
		if is_ar:
			match action:
				"move_left": act_name = "يسار"
				"move_right": act_name = "يمين"
				"move_up": act_name = "أعلى"
				"move_down": act_name = "أسفل"
				"jump": act_name = "قفز"
				"dash": act_name = "اندفاع"
				"roll": act_name = "دحرجة"
				"attack": act_name = "هجوم"
				"shield": act_name = "دفاع"
				"ui_cancel": act_name = "توقيف"
		
		# Load the matching premium texture
		var tex_path = ""
		match action:
			"move_left": tex_path = "res://assets/ui/touch_controls/left.png"
			"move_right": tex_path = "res://assets/ui/touch_controls/right.png"
			"move_up": tex_path = "res://assets/ui/touch_controls/up.png"
			"move_down": tex_path = "res://assets/ui/touch_controls/down.png"
			"jump": tex_path = "res://assets/ui/touch_controls/jump.png"
			"dash": tex_path = "res://assets/ui/touch_controls/dash.png"
			"roll": tex_path = "res://assets/ui/touch_controls/roll.png"
			"attack": tex_path = "res://assets/ui/touch_controls/attack.png"
			"shield": tex_path = "res://assets/ui/touch_controls/deffince.png"
			"ui_cancel": tex_path = "res://assets/ui/touch_controls/pause.png"
			
		if tex_path != "":
			btn.texture = load(tex_path)
			
		btn.set_meta("action_text", act_name)
		
		var default_data = InputManager.default_touch_layout[action]
		var current_data = InputManager.current_touch_layout[action]
		
		var sc = current_data["scale"]
		btn.set_meta("scale_val", sc)
		# Match in-game base scale
		var base_scale = Vector2(1.15, 1.15)
		btn.scale = sc * base_scale
		
		if btn.texture:
			var offset_val = btn.texture.get_size() / 2.0
			btn.position = current_data["pos"] - (offset_val * btn.scale)
		else:
			btn.position = current_data["pos"]
			
		var vp_size = get_viewport().get_visible_rect().size
		var b_size = btn.texture.get_size() * btn.scale if btn.texture else Vector2(100, 100)
		btn.position.x = clamp(btn.position.x, 0, max(0, vp_size.x - b_size.x))
		btn.position.y = clamp(btn.position.y, 0, max(0, vp_size.y - b_size.y))
		
		btn.gui_input.connect(_on_button_gui_input.bind(btn))
		
		buttons_parent.add_child(btn)
		
	$SaveButton.pressed.connect(_on_save_pressed)
	$CancelButton.pressed.connect(_on_cancel_pressed)
	$ResetButton.pressed.connect(_on_reset_pressed)

func _build_scale_ui() -> void:
	var top_panel = Panel.new()
	top_panel.set_anchors_preset(Control.PRESET_CENTER_TOP)
	top_panel.offset_left = -250
	top_panel.offset_top = 40
	top_panel.offset_right = 250
	top_panel.offset_bottom = 140
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	top_panel.add_theme_stylebox_override("panel", style)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 20
	vbox.offset_top = 10
	vbox.offset_right = -20
	vbox.offset_bottom = -10
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	top_panel.add_child(vbox)
	
	scale_label = Label.new()
	scale_label.text = "Select a button to resize"
	scale_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	scale_label.add_theme_font_size_override("font_size", 24)
	vbox.add_child(scale_label)
	
	scale_slider = HSlider.new()
	scale_slider.min_value = 0.5
	scale_slider.max_value = 4.0
	scale_slider.step = 0.1
	scale_slider.value = 1.5
	scale_slider.value_changed.connect(_on_scale_changed)
	vbox.add_child(scale_slider)
	
	add_child(top_panel)

func _on_button_gui_input(event: InputEvent, btn: TextureRect) -> void:
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		var is_pressed = event.is_pressed() if event is InputEventMouseButton else event.is_pressed()
		var ev_btn = event.button_index == MOUSE_BUTTON_LEFT if event is InputEventMouseButton else true
		
		if ev_btn and is_pressed:
			dragging_button = btn
			btn.z_index = 100
			
			if selected_button and selected_button != btn:
				selected_button.self_modulate = Color(1, 1, 1, 1)
				
			selected_button = btn
			selected_button.self_modulate = Color(0.3, 1.0, 0.3, 1)
			
			scale_slider.value = btn.get_meta("scale_val").x
			var t_label = "حجم: " if (Localization and Localization.current_language == "ar") else "Size: "
			scale_label.text = t_label + btn.get_meta("action_text")
			
		elif ev_btn and not is_pressed:
			if dragging_button == btn:
				dragging_button.z_index = 0
				dragging_button = null
				
	elif event is InputEventMouseMotion or event is InputEventScreenDrag:
		if dragging_button == btn:
			btn.global_position += event.relative

func _on_scale_changed(val: float) -> void:
	if selected_button:
		var new_scale = Vector2(val, val)
		var tex_size = selected_button.texture.get_size() if selected_button.texture else Vector2(100, 100)
		var old_scale = selected_button.scale
		# Pin the current visual center
		var center_pos = selected_button.position + (tex_size / 2.0 * old_scale)
		
		# Apply new scale
		selected_button.set_meta("scale_val", new_scale)
		var base_scale = Vector2(1.15, 1.15)
		selected_button.scale = new_scale * base_scale
		
		# Adjust position so the center remains perfectly still
		selected_button.position = center_pos - (tex_size / 2.0 * selected_button.scale)

func _on_save_pressed() -> void:
	for btn in buttons_parent.get_children():
		var action = btn.name
		var current_scale = btn.get_meta("scale_val")
		var tex_size = btn.texture.get_size() if btn.texture else Vector2(100, 100)
		
		# Clamp to screen to ensure it's not saved completely off-screen
		var vp_size = get_viewport().get_visible_rect().size
		var b_size = tex_size * btn.scale
		btn.position.x = clamp(btn.position.x, 0, max(0, vp_size.x - b_size.x))
		btn.position.y = clamp(btn.position.y, 0, max(0, vp_size.y - b_size.y))
		
		var center_pos = btn.position + (b_size / 2.0)
		InputManager.update_touch_position(action, center_pos, current_scale)
	
	InputManager.save_input_settings()
	InputManager.inputs_changed.emit() # Force live update in-game
	queue_free()

func _on_cancel_pressed() -> void:
	queue_free()

func _on_reset_pressed() -> void:
	for btn in buttons_parent.get_children():
		var action = btn.name
		var default_data = InputManager.default_touch_layout[action]
		var sc = default_data["scale"]
		btn.set_meta("scale_val", sc)
		var base_scale = Vector2(1.15, 1.15)
		btn.scale = sc * base_scale
		
		var tex_size = btn.texture.get_size() if btn.texture else Vector2(100, 100)
		btn.position = default_data["pos"] - (tex_size / 2.0 * btn.scale)
		InputManager.update_touch_position(action, default_data["pos"], sc)

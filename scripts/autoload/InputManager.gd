extends Node
class_name InputManagerClass

signal inputs_changed
signal input_method_changed(method)

const CONFIG_FILE = "user://input_config.cfg"

var customizable_actions = {
	"ui_cancel": {"name": "Pause", "default": KEY_ESCAPE, "default_joypad": JOY_BUTTON_START},
	"move_left": {"name": "Move Left", "default": KEY_A, "default_joypad": JOY_BUTTON_DPAD_LEFT},
	"move_right": {"name": "Move Right", "default": KEY_D, "default_joypad": JOY_BUTTON_DPAD_RIGHT},
	"move_up": {"name": "Move Up", "default": KEY_W, "default_joypad": JOY_BUTTON_DPAD_UP},
	"move_down": {"name": "Move Down", "default": KEY_S, "default_joypad": JOY_BUTTON_DPAD_DOWN},
	"jump": {"name": "Jump", "default": KEY_SPACE, "default_joypad": JOY_BUTTON_A},
	"dash": {"name": "Dash", "default": KEY_SHIFT, "default_joypad": JOY_BUTTON_RIGHT_SHOULDER},
	"roll": {"name": "Roll", "default": KEY_R, "default_joypad": JOY_BUTTON_B},
	"attack": {"name": "Attack", "default": KEY_J, "default_joypad": JOY_BUTTON_X}, 
	"shield": {"name": "Shield", "default": KEY_K, "default_joypad": JOY_BUTTON_LEFT_SHOULDER}
}

var default_touch_layout = {
	"ui_cancel": {"pos": Vector2(960, 50), "scale": Vector2(1.2, 1.2)},
	"move_left": {"pos": Vector2(100, 800), "scale": Vector2(1.5, 1.5)},
	"move_right": {"pos": Vector2(350, 800), "scale": Vector2(1.5, 1.5)},
	"move_up": {"pos": Vector2(225, 650), "scale": Vector2(1.5, 1.5)},
	"move_down": {"pos": Vector2(225, 950), "scale": Vector2(1.5, 1.5)},
	"jump": {"pos": Vector2(1700, 800), "scale": Vector2(1.5, 1.5)},
	"dash": {"pos": Vector2(1450, 800), "scale": Vector2(1.5, 1.5)},
	"roll": {"pos": Vector2(1450, 600), "scale": Vector2(1.5, 1.5)},
	"attack": {"pos": Vector2(1700, 600), "scale": Vector2(1.5, 1.5)},
	"shield": {"pos": Vector2(1700, 400), "scale": Vector2(1.5, 1.5)}
}

var current_touch_layout = {}
var current_keybindings = {}
var current_joypad_bindings = {}

var current_input_method: String = "keyboard" # touch, gamepad, keyboard

# Store original Godot project settings events so we don't delete arrow keys / mouse clicks
var base_events = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Determine initial input method heuristically
	if OS.get_name() in ["Android", "iOS", "Web"] or ProjectSettings.get_setting("input_devices/pointing/emulate_touch_from_mouse", false):
		current_input_method = "touch"
		
	# Backup original input map events before modifying
	for action in customizable_actions:
		if InputMap.has_action(action):
			base_events[action] = InputMap.action_get_events(action).duplicate()
		else:
			base_events[action] = []
			InputMap.add_action(action)
			
	load_input_settings()

func _input(event: InputEvent) -> void:
	var new_method = current_input_method
	
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		new_method = "touch"
	elif event is InputEventJoypadButton or event is InputEventJoypadMotion:
		# If it's a motion, ensure it's outside deadzone to avoid false triggers
		if event is InputEventJoypadMotion and abs(event.axis_value) < 0.2:
			pass
		else:
			new_method = "gamepad"
	elif event is InputEventKey or event is InputEventMouseButton:
		# Mouse clicks on touch-emulated Android builds often trigger alongside touches, ignore mouse if touch
		if event is InputEventMouseButton and OS.get_name() in ["Android", "iOS"]:
			pass
		else:
			new_method = "keyboard"
			
	if new_method != current_input_method:
		current_input_method = new_method
		input_method_changed.emit(current_input_method)

func load_input_settings() -> void:
	var config = ConfigFile.new()
	var err = config.load(CONFIG_FILE)
	
	if err == OK:
		# Load Keyboard & Joypad Bindings
		for action in customizable_actions:
			if config.has_section_key("keybindings", action):
				current_keybindings[action] = config.get_value("keybindings", action)
			else:
				current_keybindings[action] = customizable_actions[action]["default"]
				
			if config.has_section_key("joybindings", action):
				current_joypad_bindings[action] = config.get_value("joybindings", action)
			else:
				current_joypad_bindings[action] = customizable_actions[action]["default_joypad"]
		
		# Load Touch Layout
		for action in default_touch_layout:
			if config.has_section_key("touch_layout", action + "_pos"):
				current_touch_layout[action] = {
					"pos": config.get_value("touch_layout", action + "_pos"),
					"scale": config.get_value("touch_layout", action + "_scale", default_touch_layout[action]["scale"])
				}
			else:
				current_touch_layout[action] = default_touch_layout[action].duplicate(true)
	else:
		# Defaults
		for action in customizable_actions:
			current_keybindings[action] = customizable_actions[action]["default"]
			current_joypad_bindings[action] = customizable_actions[action]["default_joypad"]
		for action in default_touch_layout:
			current_touch_layout[action] = default_touch_layout[action].duplicate(true)
			
	apply_keybindings()

func save_input_settings() -> void:
	var config = ConfigFile.new()
	for action in current_keybindings:
		config.set_value("keybindings", action, current_keybindings[action])
	for action in current_joypad_bindings:
		config.set_value("joybindings", action, current_joypad_bindings[action])
	for action in current_touch_layout:
		config.set_value("touch_layout", action + "_pos", current_touch_layout[action]["pos"])
		config.set_value("touch_layout", action + "_scale", current_touch_layout[action]["scale"])
	config.save(CONFIG_FILE)

func apply_keybindings() -> void:
	for action in current_keybindings:
		var custom_keycode = current_keybindings[action]
		var custom_joy_btn = current_joypad_bindings[action]
		
		# 1. Clear current action events
		InputMap.action_erase_events(action)
		
		# 2. Restore base events EXCEPT the default keys/buttons
		var def_key = customizable_actions[action]["default"]
		var def_joy = customizable_actions[action]["default_joypad"]
		for base_ev in base_events[action]:
			if base_ev is InputEventKey:
				if base_ev.physical_keycode == def_key:
					continue
			elif base_ev is InputEventJoypadButton:
				if base_ev.button_index == def_joy:
					continue
			InputMap.action_add_event(action, base_ev)
			
		# 3. Add custom keyboard key
		var key_event = InputEventKey.new()
		key_event.physical_keycode = custom_keycode
		InputMap.action_add_event(action, key_event)
		
		# 4. Add custom joypad button
		var joy_event = InputEventJoypadButton.new()
		joy_event.button_index = custom_joy_btn
		InputMap.action_add_event(action, joy_event)
		
	inputs_changed.emit()

func update_keybinding(action: String, keycode: int) -> void:
	if customizable_actions.has(action):
		current_keybindings[action] = keycode
		apply_keybindings()
		save_input_settings()

func update_joybinding(action: String, joycode: int) -> void:
	if customizable_actions.has(action):
		current_joypad_bindings[action] = joycode
		apply_keybindings()
		save_input_settings()

func update_touch_position(action: String, pos: Vector2, scale: Vector2) -> void:
	if default_touch_layout.has(action):
		if not current_touch_layout.has(action):
			current_touch_layout[action] = {}
		current_touch_layout[action]["pos"] = pos
		current_touch_layout[action]["scale"] = scale

func get_action_keycode(action: String) -> int:
	if current_keybindings.has(action):
		return current_keybindings[action]
	return 0

func get_action_joycode(action: String) -> int:
	if current_joypad_bindings.has(action):
		return current_joypad_bindings[action]
	return -1


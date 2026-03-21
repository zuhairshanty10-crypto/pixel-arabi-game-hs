extends CanvasLayer

func _ready() -> void:
	if InputManager:
		InputManager.inputs_changed.connect(_update_layout)
		_update_layout()
	
	if Localization:
		Localization.language_changed.connect(_update_layout)

var last_scene_path = ""

func _process(delta: float) -> void:
	# Only show if the current scene is a level AND the active input method is touch
	var current_scene = get_tree().current_scene
	if current_scene and InputManager.current_input_method == "touch":
		var scene_name = current_scene.name
		# Show on actual levels, but hide on LevelSelection or IslandSelection
		visible = scene_name.begins_with("Level") and not "Selection" in scene_name
		
		var spath = current_scene.scene_file_path if current_scene.scene_file_path else ""
		if spath != last_scene_path:
			last_scene_path = spath
			_update_layout()
	else:
		visible = false

class DynamicTouchBtn extends TouchScreenButton:
	var action_name: String = ""
	
	func _ready():
		var tex_path = ""
		match action_name:
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
			var tex = load(tex_path)
			if tex:
				texture_normal = tex
				
		# Center the button visually so position equals center of the button
		if texture_normal:
			var offset_val = texture_normal.get_size() / 2.0
			position -= offset_val * scale
			
			# Create a tightly padded invisible hitbox so adjacent D-Pad buttons don't overlap!
			var hitbox = RectangleShape2D.new()
			# Add a modest 20-30px padding around the texture, scaled dynamically.
			hitbox.size = texture_normal.get_size() + Vector2(24, 24)
			shape = hitbox
			shape_centered = true

func _update_layout() -> void:
	# Clear existing
	for child in get_children():
		child.queue_free()
		
	if not InputManager: return
	
	var layout = InputManager.current_touch_layout
	
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path if current_scene else ""
	var is_island_4_or_5 = false
	if GameManager:
		is_island_4_or_5 = GameManager.current_island >= 4
	if "Level_4" in scene_path or "Level_5" in scene_path or "Boss" in scene_path:
		is_island_4_or_5 = true
	
	for act in InputManager.default_touch_layout:
		if act == "attack" or act == "shield":
			if not is_island_4_or_5:
				continue # Only show combat buttons on late islands
				
		var pos = InputManager.default_touch_layout[act]["pos"]
		var scl = InputManager.default_touch_layout[act]["scale"]
		if layout.has(act):
			pos = layout[act]["pos"]
			scl = layout[act]["scale"]
		
		var btn = DynamicTouchBtn.new()
		btn.action_name = act
		btn.action = act
		
		# Clamp to visible screen to prevent buttons from spawning in the void
		var vp_size = get_viewport().get_visible_rect().size
		pos.x = clamp(pos.x, 60, max(60, vp_size.x - 60))
		pos.y = clamp(pos.y, 60, max(60, vp_size.y - 60))
		
		btn.position = pos
		
		# Pixel art icons are small natively, scale them up visually to be extremely comfortable
		var base_scale = Vector2(1.15, 1.15)
		btn.scale = scl * base_scale
		
		btn.visibility_mode = TouchScreenButton.VISIBILITY_ALWAYS
		add_child(btn)

extends CanvasLayer

## In-game pause menu — toggled with ESC
## Now includes an inline settings panel (overlay, no scene change)

var is_paused: bool = false
var settings_open: bool = false
var arabic_font: Font = null

@onready var dimmer = $ColorRect
@onready var panel = $PausePanel
@onready var resume_btn = $PausePanel/VBox/ResumeButton
@onready var restart_btn = $PausePanel/VBox/RestartButton
@onready var settings_btn = $PausePanel/VBox/SettingsButton
@onready var quit_btn = $PausePanel/VBox/QuitButton
@onready var title_label = $PausePanel/VBox/Title

# Settings panel (built in _ready)
var settings_panel: Panel
var settings_title: Label
var s_music_label: Label
var s_sfx_label: Label
var s_controls_button: Button
var s_fps_label: Label
var s_lang_label: Label
var s_music_slider: HSlider
var s_sfx_slider: HSlider
var s_fps_option: OptionButton
var s_language_option: OptionButton
var s_back_button: Button

var master_bus: int
var music_bus: int
var sfx_bus: int

func _ready():
	layer = 150
	panel.hide()
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	arabic_font = load("res://assets/fonts/ArabicTypesetting.ttf")
	
	resume_btn.pressed.connect(_on_resume)
	restart_btn.pressed.connect(_on_restart)
	settings_btn.pressed.connect(_on_settings)
	quit_btn.pressed.connect(_on_quit)
	
	# Audio buses
	master_bus = AudioServer.get_bus_index("Master")
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	if music_bus < 0: music_bus = master_bus
	if sfx_bus < 0: sfx_bus = master_bus
	
	_build_settings_panel()
	
	if Localization:
		Localization.language_changed.connect(_apply_lang)
	_apply_lang()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
		if scene_name in ["MainMenu", "IslandSelection", "LevelSelection", "SettingsScreen"]:
			return
		if settings_open:
			_on_settings_back()
			get_viewport().set_input_as_handled()
			return
		toggle_pause()
		get_viewport().set_input_as_handled()

func toggle_pause():
	is_paused = !is_paused
	panel.visible = is_paused
	dimmer.visible = is_paused
	get_tree().paused = is_paused
	if is_paused:
		settings_open = false
		settings_panel.hide()
		_apply_lang()
		resume_btn.grab_focus()
		_apply_lang()
		resume_btn.grab_focus()

func _on_resume():
	toggle_pause()

func _on_restart():
	if GameManager:
		GameManager.on_player_death()
	get_tree().paused = false
	is_paused = false
	panel.hide()
	dimmer.hide()
	get_tree().reload_current_scene()

func _on_settings():
	panel.hide()
	settings_open = true
	# Sync slider values to current audio state
	s_music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	s_sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	# Sync FPS
	match Engine.max_fps:
		30: s_fps_option.selected = 0
		60: s_fps_option.selected = 1
		90: s_fps_option.selected = 2
		120: s_fps_option.selected = 3
		144: s_fps_option.selected = 4
		_: s_fps_option.selected = 1
	# Sync language
	if Localization:
		s_language_option.selected = 1 if Localization.current_language == "ar" else 0
	settings_panel.show()
	_apply_lang()
	s_back_button.grab_focus()

func _on_settings_back():
	settings_panel.hide()
	settings_open = false
	panel.show()
	if SaveManager:
		SaveManager.save_game()
	_apply_lang()
	settings_btn.grab_focus()

func _on_quit():
	get_tree().paused = false
	is_paused = false
	panel.hide()
	dimmer.hide()
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ──────────────────────────────────────────────
#  Build the settings panel programmatically
# ──────────────────────────────────────────────
func _build_settings_panel():
	# -- Panel --
	settings_panel = Panel.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -380
	settings_panel.offset_top = -340
	settings_panel.offset_right = 380
	settings_panel.offset_bottom = 340
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.06, 0.04, 0.12, 0.85)
	style.set_border_width_all(2)
	style.border_color = Color(0.5, 0.4, 0.85, 0.6)
	style.set_corner_radius_all(18)
	style.shadow_color = Color(0.3, 0.1, 0.6, 0.3)
	style.shadow_size = 12
	settings_panel.add_theme_stylebox_override("panel", style)
	settings_panel.hide()
	add_child(settings_panel)
	
	# -- VBox --
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.offset_left = 40
	vbox.offset_top = 30
	vbox.offset_right = -40
	vbox.offset_bottom = -20
	vbox.add_theme_constant_override("separation", 14)
	settings_panel.add_child(vbox)
	
	# Title
	settings_title = Label.new()
	settings_title.text = "Settings"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_color_override("font_color", Color(1, 0.9, 0.4, 1))
	settings_title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.8))
	settings_title.add_theme_constant_override("shadow_offset_x", 2)
	settings_title.add_theme_constant_override("shadow_offset_y", 3)
	settings_title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(settings_title)
	
	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer1)
	
	# -- Music Volume --
	s_music_label = _make_label("Music Volume", 26)
	vbox.add_child(s_music_label)
	s_music_slider = _make_slider()
	s_music_slider.value_changed.connect(func(v): _vol(music_bus, v))
	vbox.add_child(s_music_slider)
	_style_slider(s_music_slider)
	
	# -- SFX Volume --
	s_sfx_label = _make_label("SFX Volume", 26)
	vbox.add_child(s_sfx_label)
	s_sfx_slider = _make_slider()
	s_sfx_slider.value_changed.connect(func(v): _vol(sfx_bus, v))
	vbox.add_child(s_sfx_slider)
	_style_slider(s_sfx_slider)
	
	# Spacer
	var controls_spacer = Control.new()
	controls_spacer.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(controls_spacer)
	
	# -- Controls --
	s_controls_button = Button.new()
	s_controls_button.text = "Controls"
	s_controls_button.add_theme_font_size_override("font_size", 26)
	var btn_n_sb_c = StyleBoxFlat.new()
	btn_n_sb_c.bg_color = Color(0.08, 0.06, 0.15, 0.75)
	btn_n_sb_c.set_border_width_all(2)
	btn_n_sb_c.border_color = Color(0.6, 0.5, 0.9, 0.5)
	btn_n_sb_c.set_corner_radius_all(10)
	s_controls_button.add_theme_stylebox_override("normal", btn_n_sb_c)
	var btn_h_sb_c = StyleBoxFlat.new()
	btn_h_sb_c.bg_color = Color(0.12, 0.08, 0.25, 0.85)
	btn_h_sb_c.set_border_width_all(2)
	btn_h_sb_c.border_color = Color(0.4, 0.85, 1.0, 0.9)
	btn_h_sb_c.set_corner_radius_all(10)
	s_controls_button.add_theme_stylebox_override("hover", btn_h_sb_c)
	s_controls_button.pressed.connect(_on_controls_pressed)
	if ResourceLoader.exists("res://scripts/ui/AnimatedButton.gd"):
		s_controls_button.set_script(load("res://scripts/ui/AnimatedButton.gd"))
	vbox.add_child(s_controls_button)
	
	# -- FPS Limit --
	s_fps_label = _make_label("FPS Limit", 26)
	vbox.add_child(s_fps_label)
	s_fps_option = OptionButton.new()
	s_fps_option.add_theme_font_size_override("font_size", 26)
	for fps in ["30 FPS", "60 FPS", "90 FPS", "120 FPS", "144 FPS"]:
		s_fps_option.add_item(fps)
	s_fps_option.item_selected.connect(_on_fps_selected)
	vbox.add_child(s_fps_option)
	_style_option_button(s_fps_option)
	
	# -- Language --
	s_lang_label = _make_label("Language", 26)
	vbox.add_child(s_lang_label)
	s_language_option = OptionButton.new()
	s_language_option.add_theme_font_size_override("font_size", 26)
	s_language_option.add_item("English")
	s_language_option.add_item("العربية")
	s_language_option.item_selected.connect(_on_language_selected)
	vbox.add_child(s_language_option)
	_style_option_button(s_language_option)
	
	# Flexible spacer
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)
	
	# -- Back button --
	s_back_button = Button.new()
	s_back_button.custom_minimum_size = Vector2(240, 50)
	s_back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	s_back_button.text = "Back"
	s_back_button.add_theme_font_size_override("font_size", 28)
	var btn_n_sb = StyleBoxFlat.new()
	btn_n_sb.bg_color = Color(0.08, 0.06, 0.15, 0.75)
	btn_n_sb.set_border_width_all(2)
	btn_n_sb.border_color = Color(0.6, 0.5, 0.9, 0.5)
	btn_n_sb.set_corner_radius_all(10)
	s_back_button.add_theme_stylebox_override("normal", btn_n_sb)
	var btn_h_sb = StyleBoxFlat.new()
	btn_h_sb.bg_color = Color(0.12, 0.08, 0.25, 0.85)
	btn_h_sb.set_border_width_all(2)
	btn_h_sb.border_color = Color(0.4, 0.85, 1.0, 0.9)
	btn_h_sb.set_corner_radius_all(10)
	s_back_button.add_theme_stylebox_override("hover", btn_h_sb)
	s_back_button.pressed.connect(_on_settings_back)
	
	# Optional: attach AnimatedButton logic dynamically if present
	if ResourceLoader.exists("res://scripts/ui/AnimatedButton.gd"):
		s_back_button.set_script(load("res://scripts/ui/AnimatedButton.gd"))
		
	vbox.add_child(s_back_button)

func _make_label(text: String, size: int) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", Color(0.85, 0.8, 1.0, 1))
	return l

func _make_slider() -> HSlider:
	var s = HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.01
	s.value = 1.0
	return s

func _on_controls_pressed():
	var controls_scene = load("res://scenes/ui/ControlsScreen.tscn")
	if controls_scene:
		var overlay = controls_scene.instantiate()
		overlay.is_overlay = true  # tell the overlay it should queue_free() not change_scene
		# Need to position it properly over the pause menu layer
		add_child(overlay)

func _style_slider(slider: HSlider) -> void:
	slider.custom_minimum_size = Vector2(0, 40)
	var slider_sb = StyleBoxFlat.new()
	slider_sb.bg_color = Color(0.06, 0.04, 0.12, 0.9)
	slider_sb.set_border_width_all(2)
	slider_sb.border_color = Color(0.3, 0.2, 0.6, 0.8)
	slider_sb.set_corner_radius_all(8)
	slider_sb.content_margin_top = 16.0
	slider_sb.content_margin_bottom = 16.0
	slider.add_theme_stylebox_override("slider", slider_sb)
	var fill_sb = StyleBoxFlat.new()
	fill_sb.bg_color = Color(0.4, 0.85, 1.0, 0.9)
	fill_sb.set_corner_radius_all(8)
	fill_sb.content_margin_top = 16.0
	fill_sb.content_margin_bottom = 16.0
	slider.add_theme_stylebox_override("grabber_area", fill_sb)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill_sb)

func _style_option_button(opt: OptionButton) -> void:
	var normal_sb = StyleBoxFlat.new()
	normal_sb.bg_color = Color(0.08, 0.06, 0.18, 0.8)
	normal_sb.set_border_width_all(2)
	normal_sb.border_color = Color(0.5, 0.4, 0.85, 0.6)
	normal_sb.set_corner_radius_all(10)
	normal_sb.content_margin_left = 12.0
	normal_sb.content_margin_right = 12.0
	normal_sb.content_margin_top = 8.0
	normal_sb.content_margin_bottom = 8.0
	opt.add_theme_stylebox_override("normal", normal_sb)
	
	var hover_sb = StyleBoxFlat.new()
	hover_sb.bg_color = Color(0.12, 0.08, 0.25, 0.9)
	hover_sb.set_border_width_all(2)
	hover_sb.border_color = Color(0.4, 0.85, 1.0, 0.9)
	hover_sb.set_corner_radius_all(10)
	hover_sb.content_margin_left = 12.0
	hover_sb.content_margin_right = 12.0
	hover_sb.content_margin_top = 8.0
	hover_sb.content_margin_bottom = 8.0
	opt.add_theme_stylebox_override("hover", hover_sb)
	opt.add_theme_stylebox_override("pressed", hover_sb)
	
	opt.add_theme_color_override("font_color", Color(0.9, 0.85, 1.0, 1.0))
	opt.add_theme_color_override("font_hover_color", Color(0.4, 0.85, 1.0, 1.0))
	
	var popup: PopupMenu = opt.get_popup()
	var popup_sb = StyleBoxFlat.new()
	popup_sb.bg_color = Color(0.06, 0.04, 0.12, 0.95)
	popup_sb.set_border_width_all(2)
	popup_sb.border_color = Color(0.5, 0.4, 0.85, 0.7)
	popup_sb.set_corner_radius_all(10)
	popup_sb.content_margin_left = 8.0
	popup_sb.content_margin_right = 8.0
	popup_sb.content_margin_top = 6.0
	popup_sb.content_margin_bottom = 6.0
	popup.add_theme_stylebox_override("panel", popup_sb)
	
	var hover_item_sb = StyleBoxFlat.new()
	hover_item_sb.bg_color = Color(0.15, 0.1, 0.3, 0.9)
	hover_item_sb.set_corner_radius_all(6)
	popup.add_theme_stylebox_override("hover", hover_item_sb)
	
	popup.add_theme_color_override("font_color", Color(0.85, 0.8, 1.0, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(0.4, 0.85, 1.0, 1.0))
	popup.add_theme_font_size_override("font_size", 24)

# ──────────────────────────────────────────────
#  Settings callbacks
# ──────────────────────────────────────────────
func _on_fps_selected(index):
	var fps_values = [30, 60, 90, 120, 144]
	Engine.max_fps = fps_values[index]

func _on_language_selected(index):
	if Localization:
		Localization.set_language("ar" if index == 1 else "en")

func _vol(bus_idx, val):
	if val <= 0.01:
		AudioServer.set_bus_mute(bus_idx, true)
	else:
		AudioServer.set_bus_mute(bus_idx, false)
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(val))

# ──────────────────────────────────────────────
#  Localization
# ──────────────────────────────────────────────
func _apply_lang():
	if not Localization:
		return
	var is_ar = Localization.current_language == "ar"
	
	# Pause panel labels
	var pause_labels = [title_label, resume_btn, restart_btn, settings_btn, quit_btn]
	for l in pause_labels:
		if l:
			if is_ar and arabic_font:
				l.add_theme_font_override("font", arabic_font)
				if not l.has_meta("orig_size"):
					var c_size = 28
					if l.has_theme_font_size_override("font_size"): c_size = l.get_theme_font_size("font_size")
					l.set_meta("orig_size", c_size)
				l.add_theme_font_size_override("font_size", l.get_meta("orig_size") + 14)
			else:
				l.remove_theme_font_override("font")
				if l.has_meta("orig_size"):
					l.add_theme_font_size_override("font_size", l.get_meta("orig_size"))
	
	title_label.text = "Paused" if not is_ar else "إيقاف مؤقت"
	resume_btn.text = "Resume" if not is_ar else "متابعة"
	restart_btn.text = "Restart Level" if not is_ar else "إعادة المرحلة"
	settings_btn.text = Localization.get_text("settings")
	quit_btn.text = "Main Menu" if not is_ar else "القائمة الرئيسية"
	
	# Settings panel labels
	if settings_panel:
		var settings_labels = [settings_title, s_music_label,
			s_sfx_label, s_controls_button, s_fps_label, s_lang_label, s_back_button]
		for l in settings_labels:
			if l:
				if is_ar and arabic_font:
					l.add_theme_font_override("font", arabic_font)
				else:
					l.remove_theme_font_override("font")
		
		settings_title.text = Localization.get_text("settings_title")
		s_music_label.text = Localization.get_text("music_vol")
		s_sfx_label.text = Localization.get_text("sfx_vol")
		if s_controls_button:
			s_controls_button.text = Localization.get_text("controls") if Localization.get_text("controls") != "controls" else ("التحكم" if is_ar else "Controls")
		s_fps_label.text = Localization.get_text("fps_limit")
		s_lang_label.text = Localization.get_text("language")
		s_back_button.text = Localization.get_text("back")

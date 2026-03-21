extends CanvasLayer

## In-game pause menu — toggled with ESC
## Now includes an inline settings panel (overlay, no scene change)

var is_paused: bool = false
var settings_open: bool = false
var arabic_font: Font = null

@onready var panel = $PausePanel
@onready var resume_btn = $PausePanel/VBox/ResumeBG/ResumeButton
@onready var restart_btn = $PausePanel/VBox/RestartBG/RestartButton
@onready var settings_btn = $PausePanel/VBox/SettingsBG/SettingsButton
@onready var quit_btn = $PausePanel/VBox/QuitBG/QuitButton
@onready var title_label = $PausePanel/VBox/Title

# Settings panel (built in _ready)
var settings_panel: Panel
var settings_title: Label
var s_master_label: Label
var s_music_label: Label
var s_sfx_label: Label
var s_fps_label: Label
var s_lang_label: Label
var s_master_slider: HSlider
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
	get_tree().paused = is_paused
	if is_paused:
		settings_open = false
		settings_panel.hide()
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
	get_tree().reload_current_scene()

func _on_settings():
	panel.hide()
	settings_open = true
	# Sync slider values to current audio state
	s_master_slider.value = db_to_linear(AudioServer.get_bus_volume_db(master_bus))
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
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

# ──────────────────────────────────────────────
#  Build the settings panel programmatically
# ──────────────────────────────────────────────
func _build_settings_panel():
	var frame_tex = load("res://assets/ui/premium/Frame_tile_31.png")
	
	# -- Panel --
	settings_panel = Panel.new()
	settings_panel.set_anchors_preset(Control.PRESET_CENTER)
	settings_panel.offset_left = -380
	settings_panel.offset_top = -320
	settings_panel.offset_right = 380
	settings_panel.offset_bottom = 320
	
	var style = StyleBoxTexture.new()
	style.texture = frame_tex
	style.texture_margin_left = 12
	style.texture_margin_top = 12
	style.texture_margin_right = 12
	style.texture_margin_bottom = 12
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
	vbox.add_theme_constant_override("separation", 12)
	settings_panel.add_child(vbox)
	
	# Title
	settings_title = Label.new()
	settings_title.text = "Settings"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_color_override("font_color", Color(1, 0.9, 0.5, 1))
	settings_title.add_theme_font_size_override("font_size", 48)
	vbox.add_child(settings_title)
	
	# Spacer
	var spacer1 = Control.new()
	spacer1.custom_minimum_size = Vector2(0, 5)
	vbox.add_child(spacer1)
	
	# -- Master Volume --
	s_master_label = _make_label("Master Volume", 26)
	vbox.add_child(s_master_label)
	s_master_slider = _make_slider()
	s_master_slider.value_changed.connect(func(v): _vol(master_bus, v))
	vbox.add_child(s_master_slider)
	
	# -- Music Volume --
	s_music_label = _make_label("Music Volume", 26)
	vbox.add_child(s_music_label)
	s_music_slider = _make_slider()
	s_music_slider.value_changed.connect(func(v): _vol(music_bus, v))
	vbox.add_child(s_music_slider)
	
	# -- SFX Volume --
	s_sfx_label = _make_label("SFX Volume", 26)
	vbox.add_child(s_sfx_label)
	s_sfx_slider = _make_slider()
	s_sfx_slider.value_changed.connect(func(v): _vol(sfx_bus, v))
	vbox.add_child(s_sfx_slider)
	
	# -- FPS Limit --
	s_fps_label = _make_label("FPS Limit", 26)
	vbox.add_child(s_fps_label)
	s_fps_option = OptionButton.new()
	s_fps_option.add_theme_font_size_override("font_size", 26)
	for fps in ["30 FPS", "60 FPS", "90 FPS", "120 FPS", "144 FPS"]:
		s_fps_option.add_item(fps)
	s_fps_option.item_selected.connect(_on_fps_selected)
	vbox.add_child(s_fps_option)
	
	# -- Language --
	s_lang_label = _make_label("Language", 26)
	vbox.add_child(s_lang_label)
	s_language_option = OptionButton.new()
	s_language_option.add_theme_font_size_override("font_size", 26)
	s_language_option.add_item("English")
	s_language_option.add_item("العربية")
	s_language_option.item_selected.connect(_on_language_selected)
	vbox.add_child(s_language_option)
	
	# Flexible spacer
	var spacer2 = Control.new()
	spacer2.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer2)
	
	# -- Back button (with NinePatch background) --
	var back_bg = NinePatchRect.new()
	back_bg.custom_minimum_size = Vector2(260, 60)
	back_bg.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_bg.texture = frame_tex
	back_bg.patch_margin_left = 12
	back_bg.patch_margin_top = 12
	back_bg.patch_margin_right = 12
	back_bg.patch_margin_bottom = 12
	vbox.add_child(back_bg)
	
	s_back_button = Button.new()
	s_back_button.set_anchors_preset(Control.PRESET_FULL_RECT)
	s_back_button.text = "Back"
	s_back_button.flat = true
	s_back_button.add_theme_font_size_override("font_size", 28)
	s_back_button.pressed.connect(_on_settings_back)
	back_bg.add_child(s_back_button)

func _make_label(text: String, size: int) -> Label:
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	return l

func _make_slider() -> HSlider:
	var s = HSlider.new()
	s.min_value = 0.0
	s.max_value = 1.0
	s.step = 0.01
	s.value = 1.0
	return s

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
			else:
				l.remove_theme_font_override("font")
	
	title_label.text = "Paused" if not is_ar else "إيقاف مؤقت"
	resume_btn.text = "Resume" if not is_ar else "متابعة"
	restart_btn.text = "Restart Level" if not is_ar else "إعادة المرحلة"
	settings_btn.text = Localization.get_text("settings")
	quit_btn.text = "Main Menu" if not is_ar else "القائمة الرئيسية"
	
	# Settings panel labels
	if settings_panel:
		var settings_labels = [settings_title, s_master_label, s_music_label,
			s_sfx_label, s_fps_label, s_lang_label, s_back_button]
		for l in settings_labels:
			if l:
				if is_ar and arabic_font:
					l.add_theme_font_override("font", arabic_font)
				else:
					l.remove_theme_font_override("font")
		
		settings_title.text = Localization.get_text("settings_title")
		s_master_label.text = Localization.get_text("master_vol")
		s_music_label.text = Localization.get_text("music_vol")
		s_sfx_label.text = Localization.get_text("sfx_vol")
		s_fps_label.text = Localization.get_text("fps_limit")
		s_lang_label.text = Localization.get_text("language")
		s_back_button.text = Localization.get_text("back")

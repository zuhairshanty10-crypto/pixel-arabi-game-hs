extends Control

## Full-screen Settings — used from both Main Menu and Pause Menu

@onready var title_label = $CenterWrapper/CenterPanel/VBox/Title
@onready var music_label = $CenterWrapper/CenterPanel/VBox/MusicLabel
@onready var sfx_label = $CenterWrapper/CenterPanel/VBox/SFXLabel
@onready var fps_label = $CenterWrapper/CenterPanel/VBox/FPSLabel
@onready var lang_label = $CenterWrapper/CenterPanel/VBox/LanguageLabel
@onready var back_button = $CenterWrapper/CenterPanel/VBox/BackButton

@onready var music_slider = $CenterWrapper/CenterPanel/VBox/MusicSlider
@onready var sfx_slider = $CenterWrapper/CenterPanel/VBox/SFXSlider
@onready var fps_option = $CenterWrapper/CenterPanel/VBox/FPSOption
@onready var language_option = $CenterWrapper/CenterPanel/VBox/LanguageOption

var arabic_font: Font = null
var return_scene: String = ""

var music_bus: int
var sfx_bus: int

func _ready():
	var controls_btn = get_node_or_null("CenterWrapper/CenterPanel/VBox/ControlsButton")
	if controls_btn:
		controls_btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/ui/ControlsScreen.tscn"))
		
	tree_exiting.connect(func(): if SaveManager: SaveManager.save_game())
		
	_update_ui()
	_style_option_button(fps_option)
	_style_option_button(language_option)
	_style_slider(music_slider)
	_style_slider(sfx_slider)
	
	music_slider.grab_focus()

func _style_slider(slider: HSlider) -> void:
	# Expand the touch hitbox massively for mobile
	slider.custom_minimum_size = Vector2(0, 40)
	
	# Thick, glowing slider track
	var slider_sb = StyleBoxFlat.new()
	slider_sb.bg_color = Color(0.06, 0.04, 0.12, 0.9)
	slider_sb.set_border_width_all(2)
	slider_sb.border_color = Color(0.3, 0.2, 0.6, 0.8)
	slider_sb.set_corner_radius_all(8)
	slider_sb.content_margin_top = 16.0
	slider_sb.content_margin_bottom = 16.0
	slider.add_theme_stylebox_override("slider", slider_sb)
	
	# Bright glowing fill area
	var fill_sb = StyleBoxFlat.new()
	fill_sb.bg_color = Color(0.4, 0.85, 1.0, 0.9)
	fill_sb.set_corner_radius_all(8)
	fill_sb.content_margin_top = 16.0
	fill_sb.content_margin_bottom = 16.0
	slider.add_theme_stylebox_override("grabber_area", fill_sb)
	slider.add_theme_stylebox_override("grabber_area_highlight", fill_sb)
	
	# Massive grabber icon (we use the texture from premium, but override the styleboxes so it looks good)
	# The default grabber texture is already set in the theme, but now the track is thick enough to support it.

func _style_option_button(opt: OptionButton) -> void:
	# Style the OptionButton itself
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
	
	# Style the popup dropdown
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
	hover_item_sb.set_border_width_all(0)
	hover_item_sb.set_corner_radius_all(6)
	popup.add_theme_stylebox_override("hover", hover_item_sb)
	
	popup.add_theme_color_override("font_color", Color(0.85, 0.8, 1.0, 1.0))
	popup.add_theme_color_override("font_hover_color", Color(0.4, 0.85, 1.0, 1.0))
	popup.add_theme_color_override("font_separator_color", Color(0.5, 0.4, 0.8, 0.5))
	popup.add_theme_font_size_override("font_size", 24)

func _update_ui():
	arabic_font = load("res://assets/fonts/ArabicTypesetting.ttf")
	
	music_bus = AudioServer.get_bus_index("Music")
	sfx_bus = AudioServer.get_bus_index("SFX")
	var master_bus = AudioServer.get_bus_index("Master")
	if music_bus < 0: music_bus = master_bus
	if sfx_bus < 0: sfx_bus = master_bus
	
	# Volume sliders
	music_slider.value_changed.connect(func(v): _vol(music_bus, v))
	sfx_slider.value_changed.connect(func(v): _vol(sfx_bus, v))
	
	music_slider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus))
	sfx_slider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus))
	
	# FPS
	fps_option.item_selected.connect(_on_fps_selected)
	match Engine.max_fps:
		30: fps_option.selected = 0
		60: fps_option.selected = 1
		90: fps_option.selected = 2
		120: fps_option.selected = 3
		144: fps_option.selected = 4
		_: fps_option.selected = 1
	
	# Language
	language_option.item_selected.connect(_on_language_selected)
	if Localization:
		language_option.selected = 1 if Localization.current_language == "ar" else 0
		Localization.language_changed.connect(_apply_lang)
	
	# Back button
	back_button.pressed.connect(_on_back)
	back_button.grab_focus()
	
	# Figure out where to go back to
	if return_scene == "":
		return_scene = "res://scenes/MainMenu.tscn"
	
	_apply_lang()

func _apply_lang():
	if not Localization:
		return
	var is_ar = Localization.current_language == "ar"
	
	var controls_btn = get_node_or_null("CenterWrapper/CenterPanel/VBox/ControlsButton")
	var all_labels = [title_label, music_label, sfx_label,
		fps_label, lang_label, back_button, controls_btn]
	for l in all_labels:
		if l:
			if is_ar and arabic_font:
				l.add_theme_font_override("font", arabic_font)
				if not l.has_meta("orig_size"):
					l.set_meta("orig_size", l.get_theme_font_size("font_size"))
				var base_size = l.get_meta("orig_size")
				l.add_theme_font_size_override("font_size", base_size + 14)
			else:
				l.remove_theme_font_override("font")
				if l.has_meta("orig_size"):
					l.add_theme_font_size_override("font_size", l.get_meta("orig_size"))
	
	title_label.text = Localization.get_text("settings_title")
	music_label.text = Localization.get_text("music_vol")
	sfx_label.text = Localization.get_text("sfx_vol")
	fps_label.text = Localization.get_text("fps_limit")
	lang_label.text = Localization.get_text("language")
	back_button.text = Localization.get_text("back")
	if controls_btn:
		controls_btn.text = Localization.get_text("controls") if Localization.get_text("controls") != "controls" else ("التحكم" if is_ar else "Controls")


func _on_fps_selected(index):
	var fps_values = [30, 60, 90, 120, 144]
	Engine.max_fps = fps_values[index]

func _on_language_selected(index):
	if Localization:
		Localization.set_language("ar" if index == 1 else "en")

func _on_back():
	if SaveManager:
		SaveManager.save_game()
	get_tree().change_scene_to_file(return_scene)

func _vol(bus_idx, val):
	AudioServer.set_bus_mute(bus_idx, val <= 0.01)
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(val))

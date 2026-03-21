extends Control

## Full-screen Settings — used from both Main Menu and Pause Menu

@onready var title_label = $CenterWrapper/CenterPanel/VBox/Title
@onready var music_label = $CenterWrapper/CenterPanel/VBox/MusicLabel
@onready var sfx_label = $CenterWrapper/CenterPanel/VBox/SFXLabel
@onready var fps_label = $CenterWrapper/CenterPanel/VBox/FPSLabel
@onready var lang_label = $CenterWrapper/CenterPanel/VBox/LanguageLabel
@onready var back_button = $CenterWrapper/CenterPanel/VBox/BackBG/BackButton

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
			else:
				l.remove_theme_font_override("font")
	
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

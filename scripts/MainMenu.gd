extends Control

@export var starting_level: PackedScene

@onready var start_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/StartBG/StartButton
@onready var hardcore_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/HardcoreContainer/HardcoreBG/HardcoreButton
@onready var hardcore_info_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/HardcoreContainer/HardcoreInfoBG/HardcoreInfoButton
@onready var how_to_play_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/HowToPlayBG/HowToPlayButton
@onready var about_us_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/AboutUsBG/AboutUsButton
@onready var settings_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/SettingsBG/SettingsButton
@onready var quit_button = $UIWrapper/CenterContainer/MainVBox/VBoxContainer/QuitBG/QuitButton

@onready var how_to_play_panel = $HowToPlayPanel
@onready var close_how_to_play_button = $HowToPlayPanel/VBoxContainer/CloseHowToPlayBG/CloseHowToPlayButton

@onready var about_us_panel = $AboutUsPanel
@onready var close_about_us_button = $AboutUsPanel/VBoxContainer/CloseAboutUsBG/CloseAboutUsButton

@onready var hardcore_info_panel = $HardcoreInfoPanel
@onready var close_hardcore_info_button = $HardcoreInfoPanel/VBoxContainer/CloseHardcoreInfoBG/CloseHardcoreInfoButton

# Labels that need translation
@onready var htp_title = $HowToPlayPanel/VBoxContainer/Label
@onready var htp_desc = $HowToPlayPanel/VBoxContainer/DialogueBox/Desc
@onready var about_title = $AboutUsPanel/VBoxContainer/Label
@onready var about_desc = $AboutUsPanel/VBoxContainer/DialogueBox/Desc
@onready var hc_title = $HardcoreInfoPanel/VBoxContainer/Label
@onready var hc_desc = $HardcoreInfoPanel/VBoxContainer/DialogueBox/Desc

var arabic_font: Font = null

func _ready():
	if AudioManager:
		AudioManager.play_menu_music()
		
	start_button.grab_focus()
	arabic_font = load("res://assets/fonts/ArabicTypesetting.ttf")
	
	start_button.pressed.connect(_on_start_pressed)
	hardcore_button.pressed.connect(_on_hardcore_pressed)
	hardcore_info_button.pressed.connect(_on_hardcore_info_pressed)
	how_to_play_button.pressed.connect(_on_how_to_play_pressed)
	about_us_button.pressed.connect(_on_about_us_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	close_how_to_play_button.pressed.connect(_on_close_how_to_play)
	close_about_us_button.pressed.connect(_on_close_about_us)
	close_hardcore_info_button.pressed.connect(_on_close_hardcore_info)
	
	if Localization:
		Localization.language_changed.connect(_apply_translations)
		_apply_translations()

func _apply_translations():
	if not Localization:
		return
	
	var is_arabic = Localization.current_language == "ar"
	
	var labels_to_update = [
		start_button, hardcore_button, how_to_play_button, about_us_button,
		settings_button, quit_button,
		close_how_to_play_button, close_about_us_button, close_hardcore_info_button,
		htp_title, htp_desc, about_title, about_desc, hc_title, hc_desc
	]
	
	for lbl in labels_to_update:
		if lbl:
			if is_arabic and arabic_font:
				lbl.add_theme_font_override("font", arabic_font)
			else:
				lbl.remove_theme_font_override("font")
	
	start_button.text = Localization.get_text("start_game")
	hardcore_button.text = Localization.get_text("hardcore")
	how_to_play_button.text = Localization.get_text("how_to_play")
	about_us_button.text = Localization.get_text("about_us")
	settings_button.text = Localization.get_text("settings")
	quit_button.text = Localization.get_text("exit")
	
	close_how_to_play_button.text = Localization.get_text("back")
	close_about_us_button.text = Localization.get_text("back")
	close_hardcore_info_button.text = Localization.get_text("back")
	
	htp_title.text = Localization.get_text("how_to_play_title")
	htp_desc.text = Localization.get_text("how_to_play_desc")
	about_title.text = Localization.get_text("about_us_title")
	about_desc.text = Localization.get_text("about_us_desc")
	hc_title.text = Localization.get_text("hardcore_title")
	hc_desc.text = Localization.get_text("hardcore_desc")

func _on_start_pressed():
	if GameManager:
		GameManager.is_hardcore_mode = false
	get_tree().change_scene_to_file("res://scenes/levels/IslandSelection.tscn")

func _on_hardcore_pressed():
	if GameManager:
		if GameManager.hardcore_attempts_left <= 0:
			hardcore_info_panel.show()
			return
		GameManager.start_hardcore_run()
	get_tree().change_scene_to_file("res://scenes/levels/IslandSelection.tscn")

func _on_hardcore_info_pressed():
	hardcore_info_panel.show()
	close_hardcore_info_button.grab_focus()

func _on_close_hardcore_info():
	hardcore_info_panel.hide()
	hardcore_button.grab_focus()

func _on_how_to_play_pressed():
	how_to_play_panel.show()
	close_how_to_play_button.grab_focus()

func _on_close_how_to_play():
	how_to_play_panel.hide()
	how_to_play_button.grab_focus()

func _on_about_us_pressed():
	about_us_panel.show()
	close_about_us_button.grab_focus()

func _on_close_about_us():
	about_us_panel.hide()
	about_us_button.grab_focus()

func _on_settings_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/SettingsScreen.tscn")

func _on_quit_pressed():
	get_tree().quit()

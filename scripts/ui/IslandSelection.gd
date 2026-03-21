extends Control

@onready var buttons_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	back_button.pressed.connect(_on_back_pressed)
	
	# Connect island buttons
	for i in range(buttons_container.get_child_count()):
		var btn = buttons_container.get_child(i) as Button
		var island_num = i + 1
		
		# Check if unlocked
		if GameManager.is_island_unlocked(island_num):
			btn.disabled = false
			btn.pressed.connect(func(): _on_island_selected(island_num))
		else:
			btn.disabled = true
			btn.text += " (Locked)"

func _on_island_selected(island: int):
	GameManager.current_island = island
	get_tree().change_scene_to_file("res://scenes/ui/LevelSelection.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

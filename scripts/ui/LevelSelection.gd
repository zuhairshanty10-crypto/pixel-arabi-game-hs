extends Control

@onready var title = $VBoxContainer/Title
@onready var buttons_container = $VBoxContainer/GridContainer
@onready var back_button = $VBoxContainer/BackButton

func _ready():
	var island = GameManager.current_island
	title.text = "Island " + str(island) + " Levels"
	
	back_button.pressed.connect(_on_back_pressed)
	
	for i in range(buttons_container.get_child_count()):
		var btn = buttons_container.get_child(i) as Button
		var level_num = i + 1
		
		btn.text = str(level_num)
		
		if GameManager.is_level_unlocked(island, level_num):
			btn.disabled = false
			btn.pressed.connect(func(): _on_level_selected(level_num))
		else:
			btn.disabled = true

func _on_level_selected(level_num: int):
	GameManager.current_level = level_num
	
	# Calculate absolute level number (1 to 25)
	var absolute_level = (GameManager.current_island - 1) * 5 + level_num
	var path = "res://scenes/levels/Level_%02d.tscn" % absolute_level
	
	if ResourceLoader.exists(path):
		get_tree().change_scene_to_file(path)
	else:
		print("Level scene not found: ", path)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/ui/IslandSelection.tscn")

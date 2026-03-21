extends Area2D

@export var fake_freeze_duration: float = 1.5
var has_triggered: bool = false

@onready var color_rect: ColorRect = $CanvasLayer/ColorRect
@onready var error_label: Label = $CanvasLayer/ColorRect/Label

func _ready() -> void:
	collision_layer = 0
	collision_mask = 2 # Player
	body_entered.connect(_on_trigger)
	
	# Hide overlay initially
	color_rect.visible = false

func _on_trigger(body: Node2D) -> void:
	if not has_triggered and body.is_in_group("player"):
		has_triggered = true
		
		# Pause the game tree
		get_tree().paused = true
		
		# Show Windows style fake error overlay (Not Responding)
		color_rect.visible = true
		
		# Wait (Must use process_mode = PROCESS_MODE_ALWAYS on this node so the timer still runs)
		await get_tree().create_timer(fake_freeze_duration).timeout
		
		# Resume the game magically
		color_rect.visible = false
		get_tree().paused = false

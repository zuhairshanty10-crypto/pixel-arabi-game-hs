extends Area2D
class_name TrapBase

## Base class for all traps in Pixel Arabi.
## Extend this class and override `_trap_behavior()` for custom logic.

# If the trap should kill the player immediately on contact
@export var kill_on_contact: bool = true

func _ready() -> void:
	# Use bitwise operators to set collision layers/masks
	# Layer 3 = Traps (value = 4)
	collision_layer = 4
	
	# Mask 2 = Player (value = 2)
	collision_mask = 2
	
	# Connect to the body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Call custom initialization
	_trap_init()

func _trap_init() -> void:
	pass # Override in child classes

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die"):
		if kill_on_contact:
			body.die()
		_on_player_entered(body)

func _on_player_entered(_player: Node2D) -> void:
	pass # Override in child classes if kill_on_contact is false or extra logic needed

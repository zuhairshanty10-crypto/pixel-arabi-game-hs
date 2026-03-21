extends TrapBase

## Hidden Spike trap that springs up from the ground when stepped on

@onready var sprite: Sprite2D = $Sprite2D
@onready var kill_shape: CollisionShape2D = $CollisionShape2D
@onready var trigger_area: Area2D = $TriggerArea

var is_triggered: bool = false
var original_sprite_y: float
var original_shape_y: float

func _ready() -> void:
	super._ready() # Calls TrapBase _ready to connect signal and set up groups
	
	original_sprite_y = sprite.position.y
	
	# Disable the kill shape initially so it doesn't kill before popping up
	kill_shape.set_deferred("disabled", true)
	
	# Connect the trigger area to detect the player stepping on the invisible surface zone
	trigger_area.body_entered.connect(_on_trigger_entered)

func _on_trigger_entered(body: Node2D) -> void:
	if body is CharacterBody2D and body.has_method("die") and not is_triggered:
		is_triggered = true
		AudioManager.play_sfx(load("res://assets/sounds/spike.mp3"))
		
		# Enable the kill shape! It should now trigger the TrapBase body_entered organically
		kill_shape.set_deferred("disabled", false)
		
		# Spring up ultra rapidly! (0.015s is essentially 1 raw frame at 60fps)
		var tween = create_tween()
		tween.tween_property(sprite, "position:y", original_sprite_y - 32, 0.015).set_trans(Tween.TRANS_LINEAR)
		
		# Wait for the spike to fully emerge
		await tween.finished
		
		# Single manual check: If the player is still physically overlapping the trigger, kill them.
		# This avoids the ghost-overlap bug in _physics_process when the player teleports away to respawn.
		for b in trigger_area.get_overlapping_bodies():
			if b is CharacterBody2D and b.has_method("die") and not b.is_dead:
				b.die()
		
		# Wait 2 seconds, then reset back down
		await get_tree().create_timer(2.0).timeout
		_reset_spike()

func _reset_spike() -> void:
	# Retract back into the ground (Original position)
	var tween = create_tween()
	tween.tween_property(sprite, "position:y", original_sprite_y, 1.0)
	
	await tween.finished
	
	# Disable kill shape again once hidden
	kill_shape.set_deferred("disabled", true)
	is_triggered = false

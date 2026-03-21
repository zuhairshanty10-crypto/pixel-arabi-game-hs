extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var detection_area = $DetectionArea

var is_triggered = false
var trapped_player: CharacterBody2D = null

func _ready():
	anim_player.play("idle")

func _on_detection_area_body_entered(body):
	if body.is_in_group("player") and not is_triggered:
		is_triggered = true
		trapped_player = body
		
		# Snap player position to the mimic's mouth for dramatic effect
		if body.has_method("set_physics_process"):
			body.set_physics_process(false)
		
		var tween = create_tween()
		tween.tween_property(body, "global_position", global_position, 0.1)
		body.velocity = Vector2.ZERO
		
		anim_player.play("bite")
		
		# Actually kill the player halfway through the animation bite
		await get_tree().create_timer(0.3).timeout
		if trapped_player and trapped_player.has_method("die"):
			trapped_player.die()
			
			if trapped_player.has_method("set_physics_process"):
				trapped_player.set_physics_process(true)
			
func _on_animation_player_animation_finished(anim_name):
	if anim_name == "bite":
		# Reset back to chest form later
		await get_tree().create_timer(1.0).timeout
		anim_player.play("idle")
		is_triggered = false

extends Node2D

@onready var anim_player = $AnimationPlayer
@onready var ui_layer = $CanvasLayer
@onready var question_label = $CanvasLayer/VBoxContainer/QuestionLabel
@onready var timer_label = $CanvasLayer/VBoxContainer/TimerLabel
@onready var btn1 = $CanvasLayer/VBoxContainer/HBoxContainer/Button1
@onready var btn2 = $CanvasLayer/VBoxContainer/HBoxContainer/Button2
@onready var btn3 = $CanvasLayer/VBoxContainer/HBoxContainer/Button3
@onready var timer = $Timer
@onready var trigger_area = $TriggerArea

var is_triggered = false
var current_answer = ""
var trapped_player: CharacterBody2D = null
var solved = false

func _ready():
	ui_layer.hide()
	# Ensure the cage and its UI keep working even when the game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta):
	if is_triggered and not timer.is_stopped():
		timer_label.text = str(ceil(timer.time_left))

func _on_trigger_area_body_entered(body):
	if body.is_in_group("player") and not is_triggered and not solved:
		is_triggered = true
		trapped_player = body
		
		# Pause the rest of the game world!
		get_tree().paused = true
		
		# Center the player under the cage
		body.global_position.x = global_position.x
		body.velocity = Vector2.ZERO
		
		# Stop the player from moving
		if body.has_method("set_physics_process"):
			body.set_physics_process(false)
			
		anim_player.play("drop")
		await anim_player.animation_finished
		
		start_quiz()

func start_quiz():
	# ... (existing random question logic)
	question_label.text = ""
	var num1 = randi() % 20 + 1
	var num2 = randi() % 20 + 1
	var ops = ["+", "-", "*"]
	var op = ops[randi() % ops.size()]
	
	if op == "+":
		current_answer = str(num1 + num2)
	elif op == "-":
		if num1 < num2:
			var temp = num1
			num1 = num2
			num2 = temp
		current_answer = str(num1 - num2)
	elif op == "*":
		num1 = randi() % 10 + 1
		num2 = randi() % 10 + 1
		current_answer = str(num1 * num2)
		
	question_label.text = str(num1) + " " + op + " " + str(num2) + " = ?" 
	
	ui_layer.show()
	
	var answers = []
	var correct_val = int(current_answer)
	answers.append(correct_val)
	
	var offsets = [-3, -2, -1, 1, 2, 3, 4, 5]
	offsets.shuffle()
	
	for offset in offsets:
		if answers.size() >= 3:
			break
		var w = correct_val + offset
		if w > 0 and w not in answers:
			answers.append(w)
	
	while answers.size() < 3:
		answers.append(answers.size() + 100)
		
	answers.shuffle()
	
	btn1.text = str(answers[0])
	btn2.text = str(answers[1])
	btn3.text = str(answers[2])
	
	timer.start(5.0)

func check_answer(ans: String):
	if ans == current_answer:
		succeed()
	else:
		fail()

func _on_button1_pressed():
	check_answer(btn1.text)

func _on_button2_pressed():
	check_answer(btn2.text)

func _on_button3_pressed():
	check_answer(btn3.text)

func _on_timer_timeout():
	fail()

func succeed():
	timer.stop()
	ui_layer.hide()
	
	# Resume the game!
	get_tree().paused = false
	
	anim_player.play("raise")
	
	if trapped_player and trapped_player.has_method("set_physics_process"):
		trapped_player.set_physics_process(true)
	
	solved = true
	trigger_area.get_node("CollisionShape2D").set_deferred("disabled", true)

func fail():
	timer.stop()
	ui_layer.hide()
	
	# Resume the game so the player can die and respawn
	get_tree().paused = false
	
	if trapped_player and trapped_player.has_method("die"):
		trapped_player.die()
		
		# Re-enable player physics so they respawn properly
		if trapped_player.has_method("set_physics_process"):
			trapped_player.set_physics_process(true)
			
	# Raise the cage back up
	anim_player.play("raise")
	await anim_player.animation_finished
	
	# Reset trigger so the cage can work again on next attempt
	is_triggered = false

# Called by Player.respawn() for all nodes in "trap" group
func _reset_trap():
	timer.stop()
	ui_layer.hide()
	get_tree().paused = false # Safety unpause
	is_triggered = false
	solved = false
	trapped_player = null
	
	# Re-enable the trigger collision
	var col = trigger_area.get_node_or_null("CollisionShape2D")
	if col:
		col.set_deferred("disabled", false)
	
	# Make sure the cage is raised (reset position)
	if anim_player.is_playing():
		anim_player.stop()
	$Visuals.position = Vector2(0, -300)
	$StaticBody2D.position = Vector2(0, -300)

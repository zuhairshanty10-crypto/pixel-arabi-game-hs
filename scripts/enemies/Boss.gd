extends Node2D

enum State { IDLE, ATTACKING, DEAD }
var current_action_state: State = State.IDLE

enum Phase { PHASE_1, PHASE_2, PHASE_3 }
var current_phase: Phase = Phase.PHASE_1

@export var max_health_per_phase: int = 3
var hits_taken_this_phase: int = 0

@onready var animated_sprite = $AnimatedSprite2D
@onready var laser_sprite = $LaserSprite
@onready var hit_sound = $HitSound
@onready var right_hand_area = $RightHandArea
@onready var left_hand_area = $LeftHandArea
@onready var right_col = $RightHandArea/CollisionShape2D
@onready var left_col = $LeftHandArea/CollisionShape2D

var right_hand_deadly: bool = false
var left_hand_deadly: bool = false
var laser_deadly: bool = false

# The boss raises up so hands look like they are in the air
var idle_y_offset: float = -200.0
var is_slamming: bool = false
var base_y: float = 0.0  # Store the original Y from the scene

# Timers 
var action_timer: float = 0.0
var action_interval: float = 2.5
var spawn_enemies_timer: float = 0.0
var falling_rocks_timer: float = 0.0
var laser_cooldown: float = 0.0

func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemy")
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	if laser_sprite:
		laser_sprite.animation_finished.connect(_on_laser_finished)
		laser_sprite.frame_changed.connect(_on_laser_frame_changed)
	
	# Hand hitboxes ALWAYS enabled so player can punch them anytime
	# But hands do NOT detect the player's body (mask = 0 for body detection)
	# We use manual distance checks instead for killing
	right_col.set_deferred("disabled", false)
	left_col.set_deferred("disabled", false)
	
	# REMOVE collision_mask so hands don't auto-detect player body
	# This prevents phantom body_entered kills
	right_hand_area.collision_mask = 0
	left_hand_area.collision_mask = 0
	
	# Save base position and raise the boss up
	base_y = position.y
	position.y += idle_y_offset
	
	start_phase(Phase.PHASE_1)

func _process(delta: float) -> void:
	if current_action_state == State.DEAD:
		return
	
	# === CONTINUOUS KILL CHECK ===
	# Every frame, check if player is near a deadly hand or laser
	var player = get_tree().get_first_node_in_group("player")
	if player and not player.is_dead:
		if right_hand_deadly:
			var dist = player.global_position.distance_to(right_hand_area.global_position)
			if dist < 150:
				print("KILL: RIGHT HAND dist=", dist, " boss_y=", position.y, " player=", player.global_position)
				player.die()
		if left_hand_deadly:
			var dist = player.global_position.distance_to(left_hand_area.global_position)
			if dist < 150:
				print("KILL: LEFT HAND dist=", dist, " boss_y=", position.y, " player=", player.global_position)
				player.die()
		if laser_deadly:
			if abs(player.global_position.x - global_position.x) < 120:
				if not player.get("is_dashing") and not player.get("is_rolling"):
					print("KILL: LASER x_dist=", abs(player.global_position.x - global_position.x), " boss_y=", position.y)
					player.die()
		
	# Handle Attack Timing
	if current_action_state == State.IDLE:
		action_timer -= delta
		laser_cooldown -= delta
		
		# Fire laser even while idle to pressure the player
		if laser_cooldown <= 0.0 and current_phase != Phase.PHASE_1:
			fire_laser_only()
			laser_cooldown = randf_range(3.0, 5.0) if current_phase == Phase.PHASE_2 else randf_range(1.5, 3.0)
		
		if action_timer <= 0.0:
			perform_attack()
		
	# Spawn Enemies
	spawn_enemies_timer -= delta
	if spawn_enemies_timer <= 0.0:
		spawn_minions()
		match current_phase:
			Phase.PHASE_1: spawn_enemies_timer = randf_range(8.0, 12.0)
			Phase.PHASE_2: spawn_enemies_timer = randf_range(3.0, 5.0)
			Phase.PHASE_3: spawn_enemies_timer = randf_range(1.5, 3.0)
			
	# Phase 3: Falling Rocks
	if current_phase == Phase.PHASE_3:
		falling_rocks_timer -= delta
		if falling_rocks_timer <= 0.0:
			spawn_rock()
			falling_rocks_timer = randf_range(1.0, 2.0)

func start_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	hits_taken_this_phase = 0
	show_phase_text("Phase " + str(current_phase + 1))
	
	match current_phase:
		Phase.PHASE_1:
			action_interval = 3.0
			spawn_enemies_timer = 6.0
			print("BOSS: PHASE 1")
		Phase.PHASE_2:
			action_interval = 2.0
			spawn_enemies_timer = 3.0
			laser_cooldown = 2.0
			animated_sprite.modulate = Color(1.0, 0.7, 0.7)
			print("BOSS: PHASE 2")
		Phase.PHASE_3:
			action_interval = 1.5
			spawn_enemies_timer = 1.5
			laser_cooldown = 1.0
			falling_rocks_timer = 1.0
			animated_sprite.modulate = Color(1.0, 0.3, 0.3)
			print("BOSS: PHASE 3")

func show_phase_text(text: String) -> void:
	var canvas = CanvasLayer.new()
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 120)
	label.add_theme_color_override("font_color", Color(1, 0.1, 0.1))
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 10)
	label.set_anchors_preset(Control.PRESET_CENTER)
	label.grow_horizontal = Control.GROW_DIRECTION_BOTH
	label.grow_vertical = Control.GROW_DIRECTION_BOTH
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	canvas.add_child(label)
	add_child(canvas)
	
	var tween = create_tween()
	tween.tween_property(label, "modulate:a", 0.0, 3.0)
	tween.tween_callback(canvas.queue_free)

func fire_laser_only() -> void:
	if laser_sprite:
		laser_sprite.visible = true
		laser_sprite.play("shoot")

func perform_attack() -> void:
	current_action_state = State.ATTACKING
	is_slamming = true
	
	# Force-kill any active laser when slamming
	laser_deadly = false
	if laser_sprite:
		laser_sprite.visible = false
	
	# Tween the ENTIRE boss node DOWN to ground level
	var tween = create_tween()
	tween.tween_property(self, "position:y", base_y, 0.3).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	tween.tween_callback(func():
		if randf() > 0.5:
			animated_sprite.play("attack1")
		else:
			animated_sprite.play("attack2")
	)

func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack1":
		if animated_sprite.frame >= 3 and animated_sprite.frame <= 4:
			left_hand_deadly = true
		else:
			left_hand_deadly = false
			
	elif animated_sprite.animation == "attack2":
		if animated_sprite.frame >= 3 and animated_sprite.frame <= 4:
			right_hand_deadly = true
		else:
			right_hand_deadly = false

func _on_laser_frame_changed() -> void:
	if laser_sprite and laser_sprite.visible:
		if laser_sprite.frame >= 3 and laser_sprite.frame <= 5:
			laser_deadly = true
		else:
			laser_deadly = false

func _retract_hands() -> void:
	is_slamming = false
	right_hand_deadly = false
	left_hand_deadly = false
	laser_deadly = false
	if laser_sprite: laser_sprite.visible = false
	
	# Tween the ENTIRE boss node back UP
	var tween = create_tween()
	tween.tween_property(self, "position:y", base_y + idle_y_offset, 0.5).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(func():
		current_action_state = State.IDLE
		action_timer = action_interval
		animated_sprite.play("idle")
	)

func _on_animation_finished() -> void:
	if current_action_state == State.DEAD: return
		
	if animated_sprite.animation in ["attack1", "attack2", "hurt"]:
		_retract_hands()
	elif animated_sprite.animation == "attack7":
		current_action_state = State.IDLE
		action_timer = action_interval
		animated_sprite.play("idle")

func _on_laser_finished() -> void:
	if laser_sprite:
		laser_sprite.visible = false
		laser_deadly = false

# Called by player attack hitbox when punching the hand Area2D
func take_damage(_amount: int) -> void:
	if current_action_state == State.DEAD: return
	
	# Only take damage when hands are slammed down
	if not is_slamming: return
		
	hit_sound.play()
	hits_taken_this_phase += 1
	
	# Immediately interrupt and retract
	current_action_state = State.ATTACKING
	animated_sprite.play("hurt")
	right_hand_deadly = false
	left_hand_deadly = false
	
	# Flash white
	var tween = create_tween()
	animated_sprite.modulate = Color(10, 10, 10)
	var base_color = Color.WHITE
	match current_phase:
		Phase.PHASE_2: base_color = Color(1.0, 0.7, 0.7)
		Phase.PHASE_3: base_color = Color(1.0, 0.3, 0.3)
	tween.tween_property(animated_sprite, "modulate", base_color, 0.2)
	
	if hits_taken_this_phase >= max_health_per_phase:
		match current_phase:
			Phase.PHASE_1: start_phase(Phase.PHASE_2)
			Phase.PHASE_2: start_phase(Phase.PHASE_3)
			Phase.PHASE_3: die()

func spawn_minions() -> void:
	var root = get_tree().current_scene
	var player = get_tree().get_first_node_in_group("player")
	if not root or not player: return
		
	var pool = ["res://scenes/enemies/Skeleton.tscn", "res://scenes/enemies/Zombie.tscn"]
	if current_phase == Phase.PHASE_3: pool.append("res://scenes/enemies/Hellhound.tscn")
		
	var num_enemies = 1
	match current_phase:
		Phase.PHASE_1: num_enemies = 2
		Phase.PHASE_2: num_enemies = 4
		Phase.PHASE_3: num_enemies = 6
	
	for i in range(num_enemies):
		var enemy_scene = load(pool[randi() % pool.size()])
		if enemy_scene:
			var minion = enemy_scene.instantiate()
			var spawn_x = global_position.x + randf_range(-1000, 1000)
			if abs(spawn_x - player.global_position.x) < 200:
				spawn_x += 400 * sign(player.global_position.x - global_position.x)
			minion.global_position = Vector2(spawn_x, player.global_position.y - 100)
			root.add_child(minion)

func spawn_rock() -> void:
	var root = get_tree().current_scene
	var player = get_tree().get_first_node_in_group("player")
	if not root or not player: return
		
	var rock_scene = load("res://scenes/traps/FallingRock.tscn")
	if rock_scene:
		var rock = rock_scene.instantiate()
		rock.global_position = Vector2(player.global_position.x + randf_range(-100, 100), global_position.y - 400)
		root.add_child(rock)

func die() -> void:
	current_action_state = State.DEAD
	animated_sprite.play("death")
	right_hand_deadly = false
	left_hand_deadly = false
	laser_deadly = false
	if laser_sprite: laser_sprite.visible = false
	print("BOSS DEFEATED!")
	
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func():
		var door_scene = load("res://scenes/interactables/ExitDoor.tscn")
		if door_scene:
			var door = door_scene.instantiate()
			door.global_position = Vector2(global_position.x, global_position.y + 700)
			door.next_level_path = "res://scenes/menus/MainMenu.tscn"
			get_tree().current_scene.add_child(door)
		queue_free()
	)

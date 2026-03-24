extends CharacterBody2D

## Dark Knight Boss - Island 4 Final Boss
## A massive armored knight that chases, slashes, and teleports

enum State { IDLE, CHASE, ATTACK, HURT, TELEPORT, DEAD }
var current_state: State = State.IDLE

enum Phase { PHASE_1, PHASE_2, PHASE_3 }
var current_phase: Phase = Phase.PHASE_1

@export var max_health: int = 9
var health: int = 9
var chase_speed: float = 100.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var sword_hitbox: Area2D = $SwordHitbox
@onready var sword_col: CollisionShape2D = $SwordHitbox/CollisionShape2D

var player: CharacterBody2D = null
var attack_cooldown: float = 0.0
var attack_range: float = 120.0
var facing: int = -1  # -1 = left (faces player by default)
var teleport_positions: Array = []  # Filled on ready from arena bounds
var is_invincible: bool = false

func _ready() -> void:
	add_to_group("boss")
	add_to_group("enemy")
	health = max_health
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	animated_sprite.frame_changed.connect(_on_frame_changed)
	
	# Sword hitbox starts DISABLED
	sword_col.set_deferred("disabled", true)
	sword_hitbox.body_entered.connect(_on_sword_hit)
	
	start_phase(Phase.PHASE_1)

var spawn_timer: float = 8.0
var rock_timer: float = 3.0

func _physics_process(delta: float) -> void:
	if current_state == State.DEAD:
		return
	
	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# Find or cache player
	if not player or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player")
		if not player: 
			velocity.x = 0
			move_and_slide()
			return
	
	# Attack cooldown
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	match current_state:
		State.IDLE:
			velocity.x = 0
			# Start chasing after a brief pause
			attack_cooldown -= delta
			if attack_cooldown <= 0:
				current_state = State.CHASE
				
		State.CHASE:
			_face_player()
			velocity.x = chase_speed * facing
			animated_sprite.play("walk")
			
			# Check if close enough to attack
			var dist = abs(global_position.x - player.global_position.x)
			if dist < attack_range and attack_cooldown <= 0:
				_start_attack()
				
		State.ATTACK:
			velocity.x = 0  # Stop while attacking
			
		State.HURT:
			velocity.x = 0
			
		State.TELEPORT:
			velocity.x = 0
	
	move_and_slide()
	
	# Spawn enemies (Phase 2+)
	if current_phase != Phase.PHASE_1:
		spawn_timer -= delta
		if spawn_timer <= 0:
			_spawn_minions()
			spawn_timer = 8.0 if current_phase == Phase.PHASE_2 else 5.0
	
	# Falling rocks (Phase 3)
	if current_phase == Phase.PHASE_3:
		rock_timer -= delta
		if rock_timer <= 0:
			_spawn_rock()
			rock_timer = randf_range(1.5, 3.0)

func _face_player() -> void:
	if not player: return
	if player.global_position.x < global_position.x:
		facing = -1
		animated_sprite.flip_h = true  # Sprite faces RIGHT by default, flip to face LEFT
	else:
		facing = 1
		animated_sprite.flip_h = false  # No flip needed, already facing right

func _start_attack() -> void:
	current_state = State.ATTACK
	velocity.x = 0
	_face_player()
	
	# Pick random attack based on phase
	var attacks = ["attack1"]
	if current_phase >= Phase.PHASE_2:
		attacks.append("attack2")
	if current_phase >= Phase.PHASE_3:
		attacks.append("attack3")
	
	var chosen = attacks[randi() % attacks.size()]
	animated_sprite.play(chosen)

func _on_frame_changed() -> void:
	var anim = animated_sprite.animation
	if anim in ["attack1", "attack2", "attack3"]:
		# Enable sword hitbox on impact frames (frames 4-5 of 8)
		if animated_sprite.frame >= 4 and animated_sprite.frame <= 5:
			sword_col.set_deferred("disabled", false)
			# Position sword hitbox based on facing
			sword_hitbox.position.x = 80 * facing
		else:
			sword_col.set_deferred("disabled", true)

func _on_sword_hit(body: Node2D) -> void:
	if current_state == State.DEAD: return
	if body.is_in_group("player") and body.has_method("die"):
		if not body.is_dead:
			body.die()

func _on_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			sword_col.set_deferred("disabled", true)
			attack_cooldown = 0.5
			current_state = State.CHASE
		State.HURT:
			_do_teleport()
		State.DEAD:
			pass  # Stay dead

# Called by player's attack hitbox
func take_damage(amount: int) -> void:
	if current_state == State.DEAD or is_invincible: return
	
	health -= amount
	is_invincible = true
	sword_col.set_deferred("disabled", true)
	
	if health <= 0:
		_die()
		return
	
	# Check phase transitions
	if health == 6 and current_phase == Phase.PHASE_1:
		start_phase(Phase.PHASE_2)
	elif health == 3 and current_phase == Phase.PHASE_2:
		start_phase(Phase.PHASE_3)
	
	# Play hurt and then teleport
	current_state = State.HURT
	animated_sprite.play("hurt")
	
	# Flash white
	var tween = create_tween()
	animated_sprite.modulate = Color(10, 10, 10)
	tween.tween_property(animated_sprite, "modulate", _phase_color(), 0.15)

func _do_teleport() -> void:
	current_state = State.TELEPORT
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		# Teleport to a random arena position, away from the player
		# Arena is from x=200 to x=1700, keep same Y (ground level)
		var safe_positions = [
			Vector2(250, global_position.y),
			Vector2(500, global_position.y),
			Vector2(800, global_position.y),
			Vector2(1100, global_position.y),
			Vector2(1400, global_position.y),
			Vector2(1650, global_position.y),
		]
		
		# Pick the position farthest from the player
		var best_pos = safe_positions[0]
		var best_dist = 0.0
		for pos in safe_positions:
			var d = pos.distance_to(player.global_position) if player else 999
			if d > best_dist:
				best_dist = d
				best_pos = pos
		global_position = best_pos
		print("BOSS TELEPORTED TO: ", best_pos)
	)
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_callback(func():
		is_invincible = false
		current_state = State.IDLE
		attack_cooldown = 1.0
		animated_sprite.play("idle")
	)

func start_phase(new_phase: Phase) -> void:
	current_phase = new_phase
	_show_phase_text("Phase " + str(current_phase + 1))
	
	match current_phase:
		Phase.PHASE_1:
			chase_speed = 100.0
			print("BOSS: PHASE 1")
		Phase.PHASE_2:
			chase_speed = 150.0
			spawn_timer = 3.0
			print("BOSS: PHASE 2")
		Phase.PHASE_3:
			chase_speed = 200.0
			spawn_timer = 2.0
			rock_timer = 1.5
			print("BOSS: PHASE 3")

func _show_phase_text(text: String) -> void:
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

func _phase_color() -> Color:
	match current_phase:
		Phase.PHASE_2: return Color(1.0, 0.7, 0.7)
		Phase.PHASE_3: return Color(1.0, 0.3, 0.3)
	return Color.WHITE

func _spawn_minions() -> void:
	var root = get_tree().current_scene
	if not root or not player: return
	
	var pool = ["res://scenes/enemies/Skeleton.tscn", "res://scenes/enemies/Zombie.tscn"]
	if current_phase == Phase.PHASE_3:
		pool.append("res://scenes/enemies/Hellhound.tscn")
	
	var count = 2 if current_phase == Phase.PHASE_2 else 4
	for i in range(count):
		var scene = load(pool[randi() % pool.size()])
		if scene:
			var minion = scene.instantiate()
			var sx = global_position.x + randf_range(-800, 800)
			if abs(sx - player.global_position.x) < 200:
				sx += 400
			minion.global_position = Vector2(sx, player.global_position.y - 100)
			root.add_child(minion)

func _spawn_rock() -> void:
	var root = get_tree().current_scene
	if not root or not player: return
	var rock_scene = load("res://scenes/traps/FallingRock.tscn")
	if rock_scene:
		var rock = rock_scene.instantiate()
		rock.global_position = Vector2(player.global_position.x + randf_range(-100, 100), global_position.y - 500)
		root.add_child(rock)

func _die() -> void:
	current_state = State.DEAD
	health = 0
	velocity = Vector2.ZERO
	sword_col.set_deferred("disabled", true)
	animated_sprite.play("death")
	print("BOSS DEFEATED!")
	
	var tween = create_tween()
	tween.tween_interval(3.0)
	tween.tween_property(self, "modulate:a", 0.0, 2.0)
	tween.tween_callback(func():
		var door_scene = load("res://scenes/interactables/ExitDoor.tscn")
		if door_scene:
			var door = door_scene.instantiate()
			# Spawn door at arena center, at player's ground level
			var p = get_tree().get_first_node_in_group("player")
			var door_y = p.global_position.y if p else global_position.y
			door.global_position = Vector2(960, door_y)
			door.next_level_path = "res://scenes/levels/Level_5_1.tscn"
			get_tree().current_scene.add_child(door)
		queue_free()
	)

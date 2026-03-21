extends CharacterBody2D

## Base enemy with AI state machine
## States: IDLE, PATROL, CHASE, ATTACK, HURT, DEATH

enum State { IDLE, PATROL, CHASE, ATTACK, HURT, DEATH }

# --- Exported Config ---
@export var max_health: int = 3
@export var move_speed: float = 80.0
@export var chase_speed: float = 140.0
@export var detection_range: float = 250.0
@export var attack_range: float = 40.0
@export var attack_damage: int = 1
@export var attack_cooldown: float = 1.0
@export var knockback_force: float = 300.0
@export var patrol_distance: float = 100.0
@export var idle_wait_time: float = 2.0

# --- Internal State ---
var current_state: State = State.IDLE
var health: int = 0
@export var facing_direction: int = 1  # 1 = right, -1 = left (change to -1 to face left)
var patrol_origin: Vector2 = Vector2.ZERO
var patrol_target_x: float = 0.0
var attack_cooldown_timer: float = 0.0
var idle_timer: float = 0.0
var player: CharacterBody2D = null
var is_hurt: bool = false
var is_dead_enemy: bool = false
var spawn_position: Vector2 = Vector2.ZERO
var initial_facing: int = 1
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- Node References ---
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
var hit_sound_player: AudioStreamPlayer2D

func _ready() -> void:
	health = max_health
	patrol_origin = global_position
	spawn_position = global_position
	initial_facing = facing_direction
	patrol_target_x = patrol_origin.x + patrol_distance
	add_to_group("enemy")
	add_to_group("trap")  # So Player.respawn() calls _reset_trap()
	
	# Scale up to match player size
	animated_sprite.scale = Vector2(3.0, 3.0)
	
	# Create audio player for hit sound
	hit_sound_player = AudioStreamPlayer2D.new()
	var punch_sound = load("res://assets/sounds/punch.wav")
	if punch_sound:
		hit_sound_player.stream = punch_sound
	add_child(hit_sound_player)
	
	# Set collision so enemies don't block player movement
	# Layer 4 = enemy, Mask 1 = ground only (not player)
	collision_layer = 4
	collision_mask = 1
	
	# Find the player - search by script/node name since player may not be in a group
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		# Fallback: find by node name
		var root = get_tree().current_scene
		if root:
			var p = root.get_node_or_null("Player")
			if p:
				player = p
	
	# Connect animation finished signal
	animated_sprite.animation_finished.connect(_on_animation_finished)

func _physics_process(delta: float) -> void:
	if is_dead_enemy:
		return
	
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = min(velocity.y, 900.0)
	
	# Attack cooldown
	if attack_cooldown_timer > 0:
		attack_cooldown_timer -= delta
	
	match current_state:
		State.IDLE:
			_state_idle(delta)
		State.PATROL:
			_state_patrol(delta)
		State.CHASE:
			_state_chase(delta)
		State.ATTACK:
			_state_attack(delta)
		State.HURT:
			_state_hurt(delta)
		State.DEATH:
			velocity.x = 0
	
	move_and_slide()
	_update_animation()

# ============ STATES ============

func _state_idle(delta: float) -> void:
	velocity.x = 0
	idle_timer -= delta
	
	if _can_see_player():
		_change_state(State.CHASE)
		return
	
	# Even if detection is off, attack if player is very close
	if player and not player.is_dead and attack_cooldown_timer <= 0:
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range * 2.0:
			facing_direction = int(sign(player.global_position.x - global_position.x))
			_change_state(State.ATTACK)
			return
	
	if idle_timer <= 0 and patrol_distance > 0:
		_change_state(State.PATROL)

func _state_patrol(delta: float) -> void:
	# Move in current facing direction
	velocity.x = facing_direction * move_speed
	
	# If hit a wall, reverse direction
	if is_on_wall():
		facing_direction *= -1
		velocity.x = facing_direction * move_speed
	
	# If about to walk off an edge, reverse direction
	if is_on_floor():
		# Check if there's floor ahead using a quick test
		var test_pos = global_position + Vector2(facing_direction * 20, 10)
		var space = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(global_position + Vector2(facing_direction * 20, 0), test_pos)
		query.exclude = [get_rid()]
		var result = space.intersect_ray(query)
		if result.is_empty():
			# No floor ahead, reverse
			facing_direction *= -1
			velocity.x = facing_direction * move_speed
	
	if _can_see_player():
		_change_state(State.CHASE)

func _state_chase(delta: float) -> void:
	if not player or player.is_dead:
		_change_state(State.IDLE)
		idle_timer = idle_wait_time
		return
	
	var dist = global_position.distance_to(player.global_position)
	var dir_to_player = sign(player.global_position.x - global_position.x)
	facing_direction = int(dir_to_player) if dir_to_player != 0 else facing_direction
	
	if dist <= attack_range and attack_cooldown_timer <= 0:
		_change_state(State.ATTACK)
		return
	
	if dist > detection_range * 1.5:
		_change_state(State.IDLE)
		idle_timer = idle_wait_time
		return
	
	velocity.x = dir_to_player * chase_speed

func _state_attack(delta: float) -> void:
	velocity.x = 0
	# Attack animation handles the rest via _on_animation_finished

func _state_hurt(delta: float) -> void:
	# Knockback is applied once in take_damage, just wait for animation
	velocity.x = move_toward(velocity.x, 0, 400 * delta)

# ============ COMBAT ============

func take_damage(amount: int) -> void:
	if is_dead_enemy:
		return
		
	health -= amount
	
	# Play punch sound
	if hit_sound_player and hit_sound_player.stream:
		hit_sound_player.play()
		
	if health <= 0:
		_change_state(State.DEATH)
	else:
		_change_state(State.HURT)
		# Knockback away from player
		if player:
			var kb_dir = sign(global_position.x - player.global_position.x)
			velocity.x = kb_dir * knockback_force
			velocity.y = -150

func _deal_damage_to_player() -> void:
	if player and not player.is_dead:
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range * 1.5:
			player.die()

# ============ HELPERS ============

func _can_see_player() -> bool:
	if not player or player.is_dead:
		return false
	return global_position.distance_to(player.global_position) <= detection_range

func _change_state(new_state: State) -> void:
	current_state = new_state
	match new_state:
		State.ATTACK:
			attack_cooldown_timer = attack_cooldown

func _on_animation_finished() -> void:
	match current_state:
		State.ATTACK:
			_deal_damage_to_player()
			_change_state(State.CHASE)
		State.HURT:
			_change_state(State.CHASE)
		State.DEATH:
			# Hide and disable instead of removing
			is_dead_enemy = true
			var tween = create_tween()
			tween.tween_property(animated_sprite, "modulate:a", 0.0, 0.5)
			tween.tween_callback(func():
				visible = false
				collision_shape.set_deferred("disabled", true)
			)

func _reset_trap() -> void:
	# Called by Player.respawn() to reset all enemies
	is_dead_enemy = false
	health = max_health
	current_state = State.IDLE
	idle_timer = idle_wait_time
	global_position = spawn_position
	facing_direction = initial_facing
	velocity = Vector2.ZERO
	attack_cooldown_timer = 0.0
	visible = true
	animated_sprite.modulate.a = 1.0
	collision_shape.set_deferred("disabled", false)

func _update_animation() -> void:
	# Skeleton sprites face LEFT by default, flip when going RIGHT
	animated_sprite.flip_h = facing_direction > 0
	
	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.PATROL:
			animated_sprite.play("walk")
		State.CHASE:
			animated_sprite.play("walk")
		State.ATTACK:
			animated_sprite.play("attack")
		State.HURT:
			animated_sprite.play("hurt")
		State.DEATH:
			animated_sprite.play("death")

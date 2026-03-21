extends CharacterBody2D

## Player controller with all movement mechanics

# Movement
const SPEED = 350.0
const ACCELERATION = 2000.0
const FRICTION = 2500.0

# Jumping
const JUMP_VELOCITY = -580.0
const JUMP_CUT_MULTIPLIER = 0.4
const GRAVITY_SCALE = 1.4
const MAX_FALL_SPEED = 900.0

# Wall Jump
const WALL_JUMP_VELOCITY = Vector2(350, -450)
const WALL_SLIDE_SPEED = 120.0
const WALL_JUMP_LOCK_DURATION = 0.2

# Dash
const DASH_SPEED = 850.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.4

# Roll
const ROLL_SPEED = 500.0
const ROLL_DURATION = 0.4
const ROLL_COOLDOWN = 0.6

# Crouch
const CROUCH_SPEED = 150.0

# Coyote Time & Jump Buffer
const COYOTE_TIME = 0.1
const JUMP_BUFFER_TIME = 0.1

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# State
var is_dead: bool = false
var is_dashing: bool = false
var is_rolling: bool = false
var can_dash: bool = true
var can_roll: bool = true
var facing_direction: int = 1 # 1 = right, -1 = left
var gravity_multiplier: float = 1.0 # For gravity flip trap
var controls_inverted: bool = false # For input inversion trap
var on_ladder: bool = false
var is_climbing: bool = false
var is_crouching: bool = false
var on_ice: bool = false # Ice physics — set by IceZone areas

# Ice physics multipliers
const ICE_ACCEL_MULT = 0.12
const ICE_FRICTION_MULT = 0.03


# Timers
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_jump_lock_timer: float = 0.0
var dash_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var roll_timer: float = 0.0
var roll_cooldown_timer: float = 0.0

# Attack System
var is_attacking: bool = false
var is_shielding: bool = false
var attack_timer: float = 0.0
var attack_box: Area2D
var attack_shape: CollisionShape2D

# References
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var camera: Camera2D = $Camera2D
@onready var sfx_jump: AudioStreamPlayer2D = $SFX_Jump
@onready var sfx_dash: AudioStreamPlayer2D = $SFX_Dash
@onready var sfx_run: AudioStreamPlayer2D = $SFX_Run
@onready var sfx_die: AudioStreamPlayer = $SFX_Die
@onready var death_label: Label = $HUD/MarginContainer/HBoxContainer/DeathLabel
@onready var face_icon: TextureRect = $HUD/MarginContainer/HBoxContainer/FaceIcon
@onready var speech_bubble: Label = $HUD/SpeechBubbleContainer/SpeechBubble
@onready var wall_checker: RayCast2D = $WallChecker
@onready var ledge_checker: RayCast2D = $LedgeChecker

var taunts_ar = [
	"ههههههه لا مش معقول! 😂😂😂",
	"يلا روح العب ماينكرافت أحسنلك!",
	"أنا بتأسف لكل حدا بيشوفك بتلعب!",
	"اووف! كنت متوقع إنك سيء بس مش لهالدرجة!",
	"ما بصدق إنك فعلاً كبست Start!",
	"هاي اللعبة للأعمار ٦+... شكلك أقل!",
	"أمك كانت محقة لما قالتلك روح ذاكر!",
	"شو بتحس لما تعرف إنه طفل عمره ٥ سنين عدّاها؟",
	"حرام... بجد حرام عليك 😂",
	"أنا مللت من الانتظار وأنت بتموت!",
	"تخيّل حدا بيصور شاشتك هسا... العار! 🫣",
	"أوكي خلص أنا رسمياً فقدت الأمل فيك!",
	"إذا هاي مهاراتك ما بدي أشوف باقي حياتك!",
	"أنا حاسس إنك بتستخدم اللعبة كطريقة تعذيب!",
	"شكلك من النوع اللي بيخسر بالتيك تاك تو!",
	"أنا بموت من الضحك وانت بتموت من الفخ! 😂",
	"مش عارف مين اللي أغبى، أنت ولا اللي نصحك تلعب!",
	"أنا لو مكانك كنت انحرجت وقفلت اللعبة!",
	"هاد الفخ حرفياً كان قدام عيونك!",
	"أنت من جد بتحاول؟ لأنه مش باين!",
	"عطيني الكونترولر دقيقة بوريك كيف!",
	"معليش... مش كل الناس عندها موهبة! 🤷",
	"لو الغباء رياضة أولمبية كنت ميدالية ذهب!",
	"الفخاخ بتقول: يا سهل! جاي لحاله!",
	"شكلك من النوع اللي بيدور على واي فاي بالغابة!",
	"أنت فاشل بشكل ملهم بصراحة!",
	"واو هاي كانت أسخف موتة بتاريخ الألعاب!",
	"شو حاسس هسا؟ غضب؟ حزن؟ خجل؟ الثلاثة؟ 😏",
	"لو حطوك بلعبة سهلة بردو بتموت!",
	"أنا حرفياً بتسلى عليك أكثر ما أنت بتتسلى!",
	"صحابك لو عارفين إنك هون كانوا ماتوا ضحك!",
	"ليش بتعذب حالك؟ في ألعاب أسهل كثير!",
	"شو يعني لما اللعبة أذكى منك؟ يعني هيك!",
	"هاي مش لعبة... هاي إحراج مباشر!",
	"كل موتة بتثبتلي إنك مش جاهز!",
	"متأكد إنك مش بتلعب بعيون مسكرة؟!",
	"أنا بطلت أعد موتاتك... مليت!",
	"الشاشة حرفياً بتحكيلك وين تروح وبردو بتموت!",
	"أخوك الصغير شافك وقال: أنا أحسن منه!",
	"مبروك! حققت إنجاز جديد: فشل تام! 🏆",
	"لو في ريفيو للاعبين كنت أعطيتك ⭐ واحدة!",
	"أنا آسف بس لازم حدا يحكيلك... أنت سيء!",
	"يعني أنا صممت هاي المرحلة سهلة وبردو!",
	"الذكاء الاصطناعي بيقول: أعطوه فرصة... لا بلاش!",
	"ترا الأعداء مش صعبين، أنت بس سهل عليهم!",
	"تحدي: عيش ١٠ ثواني... شكلك مش قده!",
	"بدي أبعتلك رابط: كيف تمسك الكونترولر!",
	"لو كل حياتك زي لعبك... الله يعينك!",
	"أنا شكلي رح أضيف زر 'استسلم' خصيصي إلك!",
	"حبيبي اللعبة مش عدوتك... أنت عدو حالك!"
]

var taunts_en = [
	"That was embarrassing... even for you!",
	"My cat could've survived that! 🐱",
	"Skill issue? No, it's a YOU issue!",
	"Did you just walk INTO the trap? ON PURPOSE?",
	"I've seen tutorials play better than this!",
	"Plot twist: the floor is NOT lava... oh wait!",
	"Even the loading screen lasted longer than you!",
	"Maybe try a different hobby? 😏",
	"New record! Most deaths in history!",
	"At this rate, I'll grow old waiting for you!",
	"Your reflexes are... interesting 😬",
	"Even the spikes feel bad for you!",
	"Are you speedrunning deaths?",
	"You died. Again. I'm shocked. NOT!",
	"The enemies aren't even trying anymore!",
	"RIP. Again. And again. And again...",
	"Congrats! You found every single trap!",
	"The traps are literally celebrating right now 🎉",
	"I'm starting to think you LIKE dying!",
	"That death was so bad it lagged MY brain!",
	"Legend says one day you'll beat this level...",
	"You're making this way harder than it needs to be!",
	"Were you even looking at the screen?",
	"Your gaming chair must be broken!",
	"I'd say good luck, but it won't help 😂",
	"Google 'how to play games' real quick!",
	"Plot twist: YOU are the final boss... of failure!",
	"Maybe gaming just isn't your thing?",
	"404: Skill not found!",
	"Bruh... that was literally the easiest part!"
]

# Default sizes for crouching
@onready var default_shape_height: float = collision_shape.shape.height
@onready var default_shape_pos_y: float = collision_shape.position.y

# Spawn point
var spawn_point: Vector2 = Vector2.ZERO


func _ready() -> void:
	spawn_point = global_position
	if GameManager:
		GameManager.spawn_position = spawn_point
		GameManager.player_died.connect(_update_death_counter)
		_update_death_counter()

	# Make collision shape unique so modifying it doesn't leak
	collision_shape.shape = collision_shape.shape.duplicate()

	# Important for slope and moving platform stability
	floor_snap_length = 8.0
	
	# Fix high-FPS jitter by snapping sprite to pixel grid
	animated_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	# Camera Setup: Prevent camera from showing empty space below level
	if camera:
		var parent = get_parent()
		var bottom = parent.get_node_or_null("BottomBoundary")
		if not bottom:
			bottom = parent.get_node_or_null("BottomBoundary2")
			
		if bottom:
			camera.limit_bottom = int(bottom.global_position.y)
		
		# Immediately snap camera to player to avoid panning from old positions
		camera.reset_smoothing()

	_init_attack_system()

func _init_attack_system() -> void:
	var frames = animated_sprite.sprite_frames
	if not frames.has_animation("attack"):
		frames.add_animation("attack")
		frames.set_animation_loop("attack", false)
		frames.set_animation_speed("attack", 15.0)
		var tex = load("res://assets/player/fighter/Attack_1.png")
		if tex:
			var width = tex.get_width()
			var frames_count = int(width) / 128
			for i in range(frames_count):
				var atlas = AtlasTexture.new()
				atlas.atlas = tex
				atlas.region = Rect2(i * 128, 0, 128, 128)
				frames.add_frame("attack", atlas)
				
	if not frames.has_animation("shield"):
		frames.add_animation("shield")
		frames.set_animation_loop("shield", false)
		frames.set_animation_speed("shield", 12.0)
		var tex2 = load("res://assets/player/fighter/Shield.png")
		if tex2:
			var width = tex2.get_width()
			var frames_count = int(width) / 128
			for i in range(frames_count):
				var atlas = AtlasTexture.new()
				atlas.atlas = tex2
				atlas.region = Rect2(i * 128, 0, 128, 128)
				frames.add_frame("shield", atlas)
				
	# Create AttackBox dynamically
	attack_box = Area2D.new()
	attack_box.name = "AttackBox"
	attack_box.collision_layer = 0
	# Mask to hit everything, filter by group "enemy" later
	attack_box.collision_mask = 1 | 2 | 4 | 8 | 16
	attack_box.monitoring = true
	attack_box.monitorable = false
	
	attack_shape = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(50, 60)
	attack_shape.shape = rect
	attack_box.add_child(attack_shape)
	
	add_child(attack_box)
	attack_box.position = Vector2(35, -15)
	
	attack_shape.set_deferred("disabled", true)
	
	animated_sprite.animation_finished.connect(_on_animation_finished)
	attack_box.body_entered.connect(_on_attack_hit)
	attack_box.area_entered.connect(_on_attack_hit)

func _physics_process(delta: float) -> void:
	if is_dead:
		return
		
	if is_attacking:
		attack_timer -= delta
		if attack_timer <= 0:
			is_attacking = false
			attack_shape.set_deferred("disabled", true)
		else:
			# Apply heavy friction while attacking on ground
			if is_on_floor():
				velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
			# Apply gravity if jumping and attacking
			if not is_on_floor():
				velocity.y += gravity * GRAVITY_SCALE * gravity_multiplier * delta
				velocity.y = min(velocity.y, MAX_FALL_SPEED)
			move_and_slide()
			update_animation(0)
			return

	# Dash logic
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false
		else:
			move_and_slide()
			return
			
	# Roll logic
	if is_rolling:
		roll_timer -= delta
		if roll_timer <= 0:
			is_rolling = false
			# Restore hitbox
			collision_shape.shape.height = default_shape_height
			collision_shape.position.y = default_shape_pos_y
		else:
			# Keep rolling direction visual matching, let existing velocity dictate movement
			if velocity.x != 0:
				facing_direction = int(sign(velocity.x))
			move_and_slide()
			update_animation(0)
			return
	
	# Dash cooldown
	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta
	elif is_on_floor():
		can_dash = true
		
	# Roll cooldown
	if roll_cooldown_timer > 0:
		roll_cooldown_timer -= delta
	elif is_on_floor():
		can_roll = true
	
	# Gravity (apply ONLY if not climbing a ladder)
	if not is_on_floor() and not is_climbing:
		var grav = gravity * GRAVITY_SCALE * gravity_multiplier
		velocity.y += grav * delta
		velocity.y = min(velocity.y, MAX_FALL_SPEED)
		
		# Coyote time countdown
		coyote_timer -= delta
		
		# Wall slide
		if is_on_wall() and velocity.y > 0:
			velocity.y = min(velocity.y, WALL_SLIDE_SPEED)
	else:
		coyote_timer = COYOTE_TIME
	
	# Jump buffer countdown
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta
	
	# Get input direction
	# Get inputs
	var direction = Input.get_axis("move_left", "move_right")
	var climb_direction = Input.get_axis("move_up", "move_down") # Note: map move_up and move_down in project settings
	
	if controls_inverted:
		direction *= -1
		
	# Handle crouch
	if Input.is_action_pressed("move_down") and is_on_floor() and not is_dashing and not is_rolling and not is_climbing:
		if not is_crouching:
			is_crouching = true
			collision_shape.shape.height = default_shape_height * 0.5
			collision_shape.position.y = default_shape_pos_y + (default_shape_height * 0.25)
	else:
		if is_crouching:
			is_crouching = false
			collision_shape.shape.height = default_shape_height
			collision_shape.position.y = default_shape_pos_y
	
	var current_speed = CROUCH_SPEED if is_crouching else SPEED
	
	# Ladder Logic
	if on_ladder:
		if climb_direction != 0:
			is_climbing = true
		elif is_on_floor() and climb_direction == 0:
			# Auto-detach from ladder if standing on floor and not pressing up/down
			is_climbing = false
			
		if Input.is_action_just_pressed("jump"):
			is_climbing = false
			velocity.y = JUMP_VELOCITY
			sfx_jump.play()
	else:
		is_climbing = false
		
	if is_climbing:
		# If climbing, overwrite velocity completely 
		velocity.y = climb_direction * (SPEED * 0.5)
		velocity.x = direction * (SPEED * 0.5)
		move_and_slide()
		update_animation(direction)
		return
	
	# Horizontal movement with acceleration/friction (ice = slippery!)
	var accel = ACCELERATION * (ICE_ACCEL_MULT if on_ice else 1.0)
	var fric = FRICTION * (ICE_FRICTION_MULT if on_ice else 1.0)
	
	if wall_jump_lock_timer > 0:
		# Lock horizontal input briefly after a wall jump
		wall_jump_lock_timer -= delta
	else:
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * current_speed, accel * delta)
			facing_direction = int(sign(direction))
		else:
			velocity.x = move_toward(velocity.x, 0, fric * delta)
	
	# Jump input
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME
	
	# Execute jump (with coyote time and jump buffer)
	if jump_buffer_timer > 0:
		if is_on_floor() or coyote_timer > 0:
			# Normal jump
			velocity.y = JUMP_VELOCITY
			coyote_timer = 0
			jump_buffer_timer = 0
			sfx_jump.play()
		elif is_on_wall() and not is_on_floor() and velocity.y > 0 and (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			# Check if the wall we are touching explicitly disables wall jumps (like LeftBoundary)
			var can_wall_jump = true
			if get_slide_collision_count() > 0:
				for i in range(get_slide_collision_count()):
					var collider = get_slide_collision(i).get_collider()
					if collider and collider.has_meta("no_wall_jump"):
						can_wall_jump = false
						break
			
			# Wall jump (only when sliding down a wall and pressing against it)
			if can_wall_jump:
				var wall_normal = get_wall_normal()
				# Force the player completely away from the wall
				velocity.x = wall_normal.x * WALL_JUMP_VELOCITY.x
				velocity.y = WALL_JUMP_VELOCITY.y
				facing_direction = int(sign(wall_normal.x))
				jump_buffer_timer = 0
				wall_jump_lock_timer = WALL_JUMP_LOCK_DURATION # Disable input momentarily
				sfx_jump.play()
	
	# Variable jump height (release early = lower jump)
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= JUMP_CUT_MULTIPLIER
	
	# Dash
	if Input.is_action_just_pressed("dash") and can_dash and not is_rolling:
		start_dash()
		
	# Roll
	if Input.is_action_just_pressed("roll") and is_on_floor() and can_roll and not is_dashing:
		start_roll()
		
	# Attack (Only enabled from Island 4 onwards)
	# Fallback allows test scenes to still test attacks if island is unset
	var allow_attack = false
	if GameManager and GameManager.current_island >= 4:
		allow_attack = true
	
	if get_tree().current_scene and get_tree().current_scene.name.begins_with("Level_4"):
		allow_attack = true
		
	if allow_attack and InputMap.has_action("shield"):
		is_shielding = Input.is_action_pressed("shield") and is_on_floor() and not is_attacking and not is_dashing and not is_rolling
	else:
		is_shielding = false
		
	if is_shielding:
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		move_and_slide()
		update_animation(0)
		return
		
	var attack_pressed = false
	if allow_attack:
		if InputMap.has_action("attack"):
			attack_pressed = Input.is_action_just_pressed("attack")
		else:
			attack_pressed = Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_key_pressed(KEY_X)
			
	if attack_pressed and not is_attacking and not is_dashing and not is_rolling and not is_shielding:
		if is_on_floor() or not is_climbing:
			start_attack()
	
	# Move
	move_and_slide()
	
	# Update animation
	update_animation(direction)
	
	# Run SFX
	if is_on_floor() and not is_dashing and abs(velocity.x) > 10:
		if not sfx_run.playing:
			sfx_run.play()
	else:
		sfx_run.stop()
	
	# Check if fell off screen (1500 pixels below spawn)
	if global_position.y > (spawn_point.y + 1500):
		die()

func set_on_ladder(value: bool) -> void:
	on_ladder = value
	if not on_ladder:
		is_climbing = false

func start_dash() -> void:
	is_dashing = true
	can_dash = false
	dash_timer = DASH_DURATION
	dash_cooldown_timer = DASH_COOLDOWN
	
	# Dash in facing direction
	velocity = Vector2(facing_direction * DASH_SPEED, 0)
	sfx_dash.play()

func start_roll() -> void:
	is_rolling = true
	can_roll = false
	roll_timer = ROLL_DURATION
	roll_cooldown_timer = ROLL_COOLDOWN
	
	# Shrink hitbox much smaller to fit through tight gaps
	collision_shape.shape.height = default_shape_height * 0.3
	collision_shape.position.y = default_shape_pos_y + (default_shape_height * 0.35)
	
	sfx_dash.play() # Using dash sound for now

func start_attack() -> void:
	is_attacking = true
	attack_timer = 0.4 # Roughly enough for the animation
	# Ensure hitbox is placed correctly based on direction
	if animated_sprite.flip_h:
		attack_box.position.x = -35
	else:
		attack_box.position.x = 35
		
	attack_shape.set_deferred("disabled", false)
	_check_attack_overlaps()
	
func _check_attack_overlaps() -> void:
	await get_tree().physics_frame
	if not is_attacking: return
	
	for body in attack_box.get_overlapping_bodies():
		_on_attack_hit(body)
	for area in attack_box.get_overlapping_areas():
		_on_attack_hit(area)
	
func _on_animation_finished() -> void:
	if animated_sprite.animation == "attack":
		is_attacking = false
		attack_shape.set_deferred("disabled", true)

func _on_attack_hit(body: Node2D) -> void:
	if not is_attacking:
		return
	if body.is_in_group("enemy"):
		if body.has_method("take_damage"):
			body.take_damage(1)

func update_animation(direction: float) -> void:
	# Flip sprite based on direction
	if direction != 0 and not is_attacking:
		animated_sprite.flip_h = direction < 0
		
	if is_attacking:
		if animated_sprite.sprite_frames and animated_sprite.sprite_frames.has_animation("attack"):
			animated_sprite.play("attack")
		else:
			animated_sprite.play("idle") # Fallback if no attack animation
		return
		
	if is_shielding:
		animated_sprite.play("shield")
		return
		
	# Choose animation
	if is_climbing:
		if velocity.y > 0:
			animated_sprite.play("descend")
		elif velocity.y < 0:
			animated_sprite.play("climb")
		else:
			# Pause animation when not moving on ladder
			animated_sprite.play("climb")
			animated_sprite.pause()
	elif is_rolling:
		animated_sprite.play("roll")
	elif is_dashing:
		animated_sprite.play("run") if is_on_floor() else animated_sprite.play("jump")
	elif is_crouching:
		if abs(velocity.x) > 10:
			animated_sprite.play("crouch_walk")
		else:
			animated_sprite.play("crouch")
	elif not is_on_floor():
		animated_sprite.play("jump")
	elif abs(velocity.x) > 10:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
		
	# Unpause animation if we are no longer idle on a ladder
	if not is_climbing and not animated_sprite.is_playing():
		animated_sprite.play()


func die() -> void:
	if is_dead:
		return
	
	# If shielding, block the hit instead of dying
	if is_shielding:
		# Push player back
		velocity.x = -facing_direction * 300
		velocity.y = -100
		shake_camera(3.0, 0.15)
		return
	
	is_dead = true
	
	# Play death animation
	animated_sprite.play("dead")
	velocity = Vector2.ZERO
	sfx_die.play()
	
	# UI Taunts and Faces
	if face_icon:
		face_icon.texture = load("res://assets/player/Avatar_Sad.png")
	
	if speech_bubble:
		var taunt_list = taunts_ar if Localization.current_language == "ar" else taunts_en
		
		speech_bubble.text = taunt_list[randi() % taunt_list.size()]
		speech_bubble.visible = true
	
	# Screen shake
	shake_camera(5.0, 0.2)
	
	# Notify game manager
	if GameManager:
		GameManager.on_player_death()
	
	# Respawn after delay (enough time to read the taunt)
	await get_tree().create_timer(2.5).timeout
	
	if GameManager and GameManager.is_hardcore_mode and GameManager.hardcore_lives <= 0:
		if GameManager.hardcore_attempts_left > 0:
			GameManager.hardcore_attempts_left -= 1
		var attempts_left = GameManager.hardcore_attempts_left
		GameManager.reset_hardcore_and_fail()
		_show_hardcore_gameover(attempts_left)
	else:
		# Boss fight levels need full scene reload to reset boss state
		var scene_name = get_tree().current_scene.name if get_tree().current_scene else ""
		if scene_name.begins_with("Level_4_5") or scene_name.begins_with("Level_8_5"):
			get_tree().reload_current_scene()
		else:
			respawn()


func respawn() -> void:
	is_dead = false
	global_position = spawn_point
	velocity = Vector2.ZERO
	gravity_multiplier = 1.0
	animated_sprite.play("idle")
	
	if face_icon:
		face_icon.texture = load("res://assets/player/Avatar_Smile.png")
	if speech_bubble:
		# Keep taunt visible for 2 more seconds after respawn
		get_tree().create_timer(2.0).timeout.connect(func():
			if speech_bubble: speech_bubble.visible = false
		)
	
	# Reset any traps that need resetting (e.g. FakeDoor)
	var traps = get_tree().get_nodes_in_group("trap")
	for trap in traps:
		if trap.has_method("_reset_trap"):
			trap._reset_trap()


func shake_camera(intensity: float, duration: float) -> void:
	if not camera:
		return
	var original_offset = camera.offset
	var shake_tween = create_tween()
	for i in range(int(duration / 0.05)):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		shake_tween.tween_property(camera, "offset", offset, 0.05)
	shake_tween.tween_property(camera, "offset", original_offset, 0.05)

func _update_death_counter() -> void:
	if death_label and GameManager:
		if GameManager.is_hardcore_mode:
			death_label.text = "\u2764 " + str(GameManager.hardcore_lives)
			death_label.add_theme_color_override("font_color", Color(1, 0.84, 0))
		else:
			death_label.text = "\u2620 " + str(GameManager.deaths_total)
			death_label.add_theme_color_override("font_color", Color(1, 0.2, 0.2))

func _show_hardcore_gameover(attempts_left: int) -> void:
	# Create a full-screen game over overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.85)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -400
	vbox.offset_top = -200
	vbox.offset_right = 400
	vbox.offset_bottom = 200
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 30)
	
	var title = Label.new()
	title.text = "GAME OVER"
	title.add_theme_font_size_override("font_size", 72)
	title.add_theme_color_override("font_color", Color(1, 0.2, 0.2))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var msg = Label.new()
	if attempts_left > 0:
		msg.text = "Better luck next time!\nYou have " + str(attempts_left) + " attempt(s) left."
	else:
		msg.text = "Better luck next time!\nNo attempts remaining."
	msg.add_theme_font_size_override("font_size", 36)
	msg.add_theme_color_override("font_color", Color(1, 1, 1))
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg)
	
	var btn = Button.new()
	btn.text = "Back to Menu"
	btn.add_theme_font_size_override("font_size", 32)
	btn.custom_minimum_size = Vector2(300, 70)
	btn.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/MainMenu.tscn"))
	vbox.add_child(btn)
	
	overlay.add_child(vbox)
	
	var canvas = CanvasLayer.new()
	canvas.layer = 200
	canvas.add_child(overlay)
	get_tree().current_scene.add_child(canvas)

func show_hardcore_win() -> void:
	# Create a full-screen win overlay
	var overlay = ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.9)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	var vbox = VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_CENTER)
	vbox.offset_left = -450
	vbox.offset_top = -250
	vbox.offset_right = 450
	vbox.offset_bottom = 250
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 25)
	
	var title = Label.new()
	title.text = "CONGRATULATIONS!"
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(1, 0.84, 0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	var msg = Label.new()
	msg.text = "You won $100!\nTake a screenshot and send it\nvia WhatsApp to:\n00962796459266"
	msg.add_theme_font_size_override("font_size", 36)
	msg.add_theme_color_override("font_color", Color(1, 1, 1))
	msg.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(msg)
	
	var btn = Button.new()
	btn.text = "Back to Menu"
	btn.add_theme_font_size_override("font_size", 32)
	btn.custom_minimum_size = Vector2(300, 70)
	btn.pressed.connect(func():
		if GameManager: GameManager.is_hardcore_mode = false
		get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
	)
	vbox.add_child(btn)
	
	overlay.add_child(vbox)
	
	var canvas = CanvasLayer.new()
	canvas.layer = 200
	canvas.add_child(overlay)
	get_tree().current_scene.add_child(canvas)

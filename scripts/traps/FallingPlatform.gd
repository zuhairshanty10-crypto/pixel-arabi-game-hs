extends AnimatableBody2D

# A platform that falls a short duration after the player steps on it.

@export var fall_delay: float = 0.5
@export var shake_intensity: float = 3.0
@export var fall_speed: float = 600.0
@export var gravity: float = 1200.0

var is_triggered: bool = false
var is_falling: bool = false
var has_fallen: bool = false
var current_fall_velocity: float = 0.0
var original_position: Vector2

@onready var sprite: Sprite2D = $Sprite2D
@onready var trigger_area: Area2D = $TriggerArea

func _ready() -> void:
    original_position = global_position
    collision_layer = 1 # Solid world collision
    trigger_area.body_entered.connect(_on_trigger_body_entered)
    
    # Listen for player respawns to reset the trap
    if GameManager:
        GameManager.level_started.connect(reset_platform)
        GameManager.player_died.connect(func(): await get_tree().create_timer(0.6).timeout; reset_platform())

func _physics_process(delta: float) -> void:
    if has_fallen:
        return
        
    if is_triggered and not is_falling:
        # Shake effect
        sprite.position = Vector2(
            randf_range(-shake_intensity, shake_intensity),
            randf_range(-shake_intensity, shake_intensity)
        )
    
    if is_falling:
        current_fall_velocity += gravity * delta
        current_fall_velocity = min(current_fall_velocity, fall_speed)
        global_position.y += current_fall_velocity * delta
        
        # Stop processing if fallen way off screen
        if global_position.y > original_position.y + 1500:
            shatter()

func _on_trigger_body_entered(body: Node2D) -> void:
    if not is_triggered and body.is_in_group("player"):
        is_triggered = true
        
        # Wait for delay before falling
        await get_tree().create_timer(fall_delay).timeout
        
        is_falling = true
        sprite.position = Vector2.ZERO # Reset sprite shake position
        
        # Disable solid collision so it drops through everything and player falls with it
        collision_layer = 0
        collision_mask = 0

func shatter() -> void:
    is_falling = false
    has_fallen = true
    visible = false

func reset_platform() -> void:
    global_position = original_position
    current_fall_velocity = 0.0
    is_triggered = false
    is_falling = false
    has_fallen = false
    visible = true
    collision_layer = 1
    collision_mask = 1
    sprite.position = Vector2.ZERO

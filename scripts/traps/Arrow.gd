extends TrapBase

# Arrow projectile spawned by the ArrowShooter trap.

@export var speed: float = 400.0
@export var direction: Vector2 = Vector2.RIGHT
@export var lifetime: float = 3.0

var velocity: Vector2 = Vector2.ZERO

func _trap_init() -> void:
	velocity = direction.normalized() * speed
	
	# Despawn automatically
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_entered(body: Node2D) -> void:
	# Ignore other traps, only hit World (layer 1) or Player (layer 2)
	# Kill player on contact via TrapBase
	super._on_body_entered(body)
	# Destroy arrow on hitting anything
	queue_free()

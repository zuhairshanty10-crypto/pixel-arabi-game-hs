@tool
extends Area2D

@export var blocks: int = 1:
	set(value):
		blocks = max(1, value)
		if is_inside_tree():
			_update_size()

func _ready():
	_update_size()

func _update_size():
	var tex = get_node_or_null("TextureRect")
	var col = get_node_or_null("CollisionShape2D")
	if not tex or not col: return
	
	var h = 74.0 * blocks
	tex.size.y = h
	tex.position.y = -h / 2.0
	
	if col.shape and col.shape is RectangleShape2D:
		col.shape.size.y = h

func _on_body_entered(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player") and body.has_method("set_on_ladder"):
		body.set_on_ladder(true)

func _on_body_exited(body):
	if Engine.is_editor_hint(): return
	if body.is_in_group("player") and body.has_method("set_on_ladder"):
		body.set_on_ladder(false)

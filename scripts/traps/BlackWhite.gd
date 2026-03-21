extends Area2D

@export var duration: float = 8.0

var effect_active = false
var _sprite: Sprite2D = null
var _frame: float = 0.0
@export var animation_fps: float = 12.0

func _ready():
	for child in get_children():
		if child is Sprite2D:
			_sprite = child
			break

func _process(delta):
	if _sprite and _sprite.hframes > 1:
		_frame += animation_fps * delta
		var max_frames = _sprite.hframes
		if _frame >= max_frames:
			_frame = 0
		var frame_int = int(_frame)
		if frame_int == 11: frame_int = 12
		_sprite.frame = min(frame_int, max_frames - 1)

func _on_body_entered(body):
	if body.is_in_group("player") and not effect_active:
		effect_active = true
		_apply_grayscale()

func _apply_grayscale():
	# Create a full-screen grayscale overlay
	var canvas = CanvasLayer.new()
	canvas.name = "GrayscaleEffect"
	canvas.layer = 99
	
	var rect = ColorRect.new()
	rect.anchors_preset = 15  # Full rect
	rect.anchor_right = 1.0
	rect.anchor_bottom = 1.0
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Grayscale shader (Godot 4.x compatible)
	var shader = Shader.new()
	shader.code = """
shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
void fragment() {
	vec4 screen_color = texture(screen_texture, SCREEN_UV);
	float gray = dot(screen_color.rgb, vec3(0.299, 0.587, 0.114));
	COLOR = vec4(vec3(gray), 1.0);
}
"""
	var mat = ShaderMaterial.new()
	mat.shader = shader
	rect.material = mat
	
	canvas.add_child(rect)
	get_tree().current_scene.add_child(canvas)
	
	# Wait for duration then remove
	await get_tree().create_timer(duration).timeout
	
	if is_instance_valid(canvas):
		canvas.queue_free()
	effect_active = false

func _reset_trap():
	effect_active = false
	var existing = get_tree().current_scene.get_node_or_null("GrayscaleEffect")
	if existing:
		existing.queue_free()

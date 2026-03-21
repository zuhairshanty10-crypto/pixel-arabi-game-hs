extends ParallaxBackground

@export var parallax_speed: float = 50.0

func _process(delta):
	scroll_offset.x -= parallax_speed * delta

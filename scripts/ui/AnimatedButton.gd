extends Button
## AnimatedButton — Attach to any Button for smooth hover/press animations

func _ready() -> void:
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_unhover)
	focus_entered.connect(_on_hover)
	focus_exited.connect(_on_unhover)
	button_down.connect(_on_press)
	button_up.connect(_on_release)
	pivot_offset = size / 2.0
	resized.connect(func(): pivot_offset = size / 2.0)

func _on_hover() -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.15)

func _on_unhover() -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

func _on_press() -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2(0.95, 0.95), 0.08)

func _on_release() -> void:
	var tw = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tw.tween_property(self, "scale", Vector2(1.08, 1.08), 0.08)

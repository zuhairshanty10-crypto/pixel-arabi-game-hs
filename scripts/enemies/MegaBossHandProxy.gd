extends Area2D

func take_damage(amount: int) -> void:
	var boss = get_parent()
	if boss and boss.has_method('take_damage'):
		boss.take_damage(amount)

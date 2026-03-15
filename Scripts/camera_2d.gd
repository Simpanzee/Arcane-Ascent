extends Camera2D
var shake_strength: float = 0.0
var shake_fade: float = 8.0

func shake(amount: float):
	shake_strength = amount

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerp(shake_strength, 0.0, shake_fade * delta)
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		offset = Vector2.ZERO

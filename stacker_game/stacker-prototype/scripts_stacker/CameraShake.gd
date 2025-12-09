extends Camera2D

var shake_amount := 0.0
var shake_decay := 5.0

func _process(delta):
	if shake_amount > 0.0:
		offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		shake_amount = lerp(shake_amount, 0.0, float(shake_decay) * delta)
	else:
		offset = Vector2.ZERO

func shake(power):
	shake_amount = power

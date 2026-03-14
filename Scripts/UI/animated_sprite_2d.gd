extends AnimatedSprite2D

@onready var sprite: AnimatedSprite2D = $"../../Player/AnimatedSprite2D"

func _process(_delta):

	var anim = sprite.animation
	if anim == "walk":
		anim = "idle"
	if animation != anim:
		play(anim)

	frame = sprite.frame
	speed_scale = sprite.speed_scale

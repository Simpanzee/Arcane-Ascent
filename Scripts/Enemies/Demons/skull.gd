extends Enemy

@onready var critical = $Critical

func _ready() -> void:
	super()
	cur_hp = 1
	max_hp = 1
	move_speed = 75

	attack_damage = 5
	attack_range = 15
	attack_rate = 1.5

	apply_modifiers()

	hurt_pitch = [0.8, 1.0]
	death_pitch = [0.5, 2]
	despawn_pitch = [0.8, 1.2]

func _try_attack():
	if not super():
		return

	sprite.play("attack")
	await get_tree().create_timer(0.05).timeout

	if state == "dead":
		return

	attack.pitch_scale = randf_range(0.5, 2)
	attack.play()

	if is_instance_valid(player) and not player.is_dead:
		var dist = global_position.distance_to(player.global_position)
		if dist <= attack_range:
			critical.play()
			player.take_damage_ignore_invul(attack_damage)

	cur_hp = 0
	healthChanged.emit()
	state = "dead"
	velocity = Vector2.ZERO
	await sprite.animation_finished
	await attack.finished

	died.emit()
	queue_free()

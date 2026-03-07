extends Enemy

func _ready() -> void:
	super()
	cur_hp = 1
	max_hp = 1
	move_speed = 55

	attack_damage = 1
	attack_range = 15
	attack_rate = 1.5
	
	hurt_pitch = [0.5, 2]
	death_pitch = [0.5, 2]
	despawn_pitch = [0.8, 1.2]

func _try_attack():
	if !super():
		return

	sprite.play("attack")
	await get_tree().create_timer(0.3).timeout
	
	if state == "dead":
		return
	
	attack.pitch_scale = randf_range(0.5, 2)
	attack.play()

	var dist = global_position.distance_to(player.global_position)
	if dist <= attack_range:
		player.take_damage(attack_damage)

	await sprite.animation_finished
	if state != "dead":
		state = "move"

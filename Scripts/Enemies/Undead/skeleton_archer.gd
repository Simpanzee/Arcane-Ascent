extends Enemy

@export var idle_after_shot: float = 0.8
@export var arrow_scene: PackedScene

func _ready() -> void:
	super()
	cur_hp = 2
	max_hp = 2
	move_speed = 50

	attack_damage = 1
	attack_range = 110
	attack_rate = 2.5

	apply_modifiers()

	hurt_pitch = [0.5, 2]
	death_pitch = [0.5, 2]
	despawn_pitch = [0.8, 1.2]


func _physics_process(_delta: float) -> void:
	if not is_active:
		return

	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		return

	if state == "dead":
		return

	if player.is_dead:
		velocity = Vector2.ZERO
		sprite.play("idle")
		return

	if state != "move":
		velocity = Vector2.ZERO
		return

	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)

	sprite.flip_h = player_direction.x < 0
	if player_distance <= attack_range:
		velocity = Vector2.ZERO
		sprite.play("idle")
		_try_attack()
		return

	velocity = player_direction * move_speed * speed_multiplier
	sprite.play("move")
	move_and_slide()


func _try_attack():
	if not super():
		return

	if state == "dead":
		return

	velocity = Vector2.ZERO
	sprite.play("attack")

	attack.pitch_scale = randf_range(0.8, 1.1)
	attack.play()

	await get_tree().create_timer(0.6).timeout

	if state == "dead":
		return

	if player == null or not is_instance_valid(player):
		return

	# Shoot toward the player's current position.
	player_direction = global_position.direction_to(player.global_position)

	var arrow = arrow_scene.instantiate()
	arrow.damage = attack_damage
	arrow.direction = player_direction
	arrow.global_position = global_position

	get_tree().current_scene.add_child(arrow)

	await sprite.animation_finished

	if state == "dead":
		return

	sprite.play("idle")
	await get_tree().create_timer(idle_after_shot).timeout

	if state != "dead":
		state = "move"

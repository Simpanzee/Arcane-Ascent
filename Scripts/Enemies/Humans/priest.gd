
extends Enemy

# Healing
@export var heal_scene: PackedScene
@export var heal_amount: int = 1
@export var heal_radius: float = 100.0
@export var heal_cooldown: float = 8.0
@export var heal_animation_delay: float = 0.3

# Holy attack
@export var holy_scene: PackedScene
@export var attack_cooldown: float = 4.0
@export var attack_animation_delay: float = 0.4

# Movement
@export var flee_speed: float = 80.0
@export var ideal_min_range: float = 50.0
@export var ideal_max_range: float = 100.0
@export var strafe_speed: float = 80.0
@export var holy_range: float = 120.0

var last_heal_time: float = -1000.0
var healing_in_progress: bool = false
var attacking_in_progress: bool = false
var strafe_dir: int = 1


func _ready() -> void:
	super()

	cur_hp = 3
	max_hp = 3
	move_speed = 55

	# Use the inherited attack timer from Enemy.gd.
	last_attack_time = -1000.0

	hurt_pitch = [0.5, 2.0]
	death_pitch = [0.5, 2.0]
	despawn_pitch = [0.8, 1.2]

	add_to_group("Enemy")


func _physics_process(_delta: float) -> void:
	if not is_active:
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	if state == "dead":
		return

	if state == "rooted":
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	if state == "hurt":
		return

	if player == null or not is_instance_valid(player):
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	if player.is_dead:
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	sprite.flip_h = player_direction.x < 0

	# Healing takes priority over attacking.
	if not healing_in_progress and not attacking_in_progress:
		if _can_heal() and _has_injured_allies():
			_start_healing()
			return

	# Wait while healing or attacking.
	if healing_in_progress or attacking_in_progress:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Attack when healing is not needed.
	if _can_attack():
		_start_attack()
		return

	# Keep moving between actions.
	_strafe()


# HEALING

func _has_injured_allies() -> bool:
	for body in get_tree().get_nodes_in_group("Enemy"):
		if not is_instance_valid(body):
			continue

		if body == self or not body is Enemy:
			continue

		if body.state == "dead":
			continue

		if body.cur_hp >= body.max_hp:
			continue

		if global_position.distance_to(body.global_position) <= heal_radius:
			return true

	return false


func _can_heal() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	return current_time - last_heal_time >= heal_cooldown


func _start_healing() -> void:
	if healing_in_progress or attacking_in_progress:
		return

	healing_in_progress = true
	last_heal_time = Time.get_ticks_msec() / 1000.0

	velocity = Vector2.ZERO
	state = "heal"
	sprite.play("heal")

	_perform_heal()


func _perform_heal() -> void:
	await get_tree().create_timer(heal_animation_delay).timeout

	if not is_instance_valid(self):
		return

	if state != "heal":
		healing_in_progress = false
		return

	if heal_scene != null:
		for body in get_tree().get_nodes_in_group("Enemy"):
			if not is_instance_valid(body):
				continue

			if body == self or not body is Enemy:
				continue

			if body.state == "dead" or body.state == "rooted":
				continue

			if body.cur_hp >= body.max_hp:
				continue

			if global_position.distance_to(body.global_position) > heal_radius:
				continue

			var heal_effect = heal_scene.instantiate()
			heal_effect.heal_amount = heal_amount
			body.add_child(heal_effect)
			heal_effect.position = Vector2.ZERO

	# Finish the healing animation.
	if sprite.sprite_frames.has_animation("heal"):
		if sprite.animation == "heal" and sprite.is_playing():
			await sprite.animation_finished

	if not is_instance_valid(self):
		return

	healing_in_progress = false

	if state == "heal":
		state = "move"

func _can_attack() -> bool:
	var current_time = Time.get_ticks_msec() / 1000.0
	return (
		current_time - last_attack_time >= attack_cooldown
		and player_distance <= holy_range
	)

func _start_attack() -> void:
	if attacking_in_progress or healing_in_progress:
		return

	if holy_scene == null:
		return

	if player == null or not is_instance_valid(player):
		return

	attacking_in_progress = true
	last_attack_time = Time.get_ticks_msec() / 1000.0

	velocity = Vector2.ZERO
	state = "attack"

	if sprite.sprite_frames.has_animation("attack"):
		sprite.play("attack")
	else:
		sprite.play("idle")

	# Summon holy magic at the player's current position.
	var holy = holy_scene.instantiate()
	get_tree().current_scene.add_child(holy)
	holy.global_position = player.global_position

	_finish_attack()


func _finish_attack() -> void:
	await get_tree().create_timer(attack_animation_delay).timeout

	if not is_instance_valid(self):
		return

	attacking_in_progress = false

	if state == "attack":
		state = "move"


# MOVEMENT AND STRAFING

func _strafe() -> void:
	var separation: Vector2
	var move_dir: Vector2

	# Move away if too close to the player.
	if player_distance < ideal_min_range:
		separation = get_separation_force() * separation_strength
		move_dir = (-player_direction + separation).normalized()

		velocity = move_dir * flee_speed * speed_multiplier
		sprite.play("move")
		move_and_slide()
		return

	# Strafe around the player at medium range.
	if player_distance <= ideal_max_range:
		if randf() < 0.01:
			strafe_dir *= -1

		var strafe_vector = Vector2(
			-player_direction.y,
			player_direction.x
		) * strafe_dir

		separation = get_separation_force()
		move_dir = (strafe_vector + separation).normalized()

		velocity = move_dir * strafe_speed * speed_multiplier
		sprite.play("move")
		move_and_slide()
		return

	# Approach the player if too far away.
	separation = get_separation_force() * separation_strength
	move_dir = (player_direction + separation).normalized()

	velocity = move_dir * move_speed * speed_multiplier
	sprite.play("move")
	move_and_slide()

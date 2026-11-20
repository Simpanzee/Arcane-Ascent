extends Enemy

@onready var attack1_hitbox = $Attack1Hitbox
@onready var attack2_hitbox = $Attack2Hitbox
@onready var attack3_hitbox = $Attack3Hitbox

@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")

@onready var attack2 = $Attack2
@onready var attack3 = $Attack3
@onready var critical = $Critical

@export var leap_speed: float = 100.0
@export var leap_duration: float = 0.8
@export var leap_range: float = 80.0
@export var leap_cooldown_min: float = 10.0
@export var leap_cooldown_max: float = 30.0

var leap_cooldown: float = 20.0
var last_leap_time: float = 0.0
var leap_direction: Vector2
var is_leaping: bool = false
var is_attack4_leaping: bool = false
var is_attack4_active: bool = false
var attack4_cancelled: bool = false

func _ready() -> void:
	super()

	cur_hp = 10
	max_hp = 10
	move_speed = 40

	attack_damage = 3
	attack_range = 35
	attack_rate = 1.7

	apply_modifiers()

	hurt_pitch = [0.5, 0.8]
	death_pitch = [0.8, 1.2]
	despawn_pitch = [0.8, 1.2]

	attack1_hitbox.monitoring = false
	attack2_hitbox.monitoring = false
	attack3_hitbox.monitoring = false

	attack1_hitbox.body_entered.connect(_on_attack1_hitbox_body_entered)
	attack2_hitbox.body_entered.connect(_on_attack2_hitbox_body_entered)
	attack3_hitbox.body_entered.connect(_on_attack3_hitbox_body_entered)

	leap_cooldown = randf_range(leap_cooldown_min, leap_cooldown_max)
	last_leap_time = Time.get_ticks_msec() / 1000.0

func _process(_delta: float) -> void:
	if state == "dead":
		return

	var hp_percentage = float(cur_hp) / float(max_hp)

	if hp_percentage > 0.66:
		move_speed = 45
	elif hp_percentage > 0.33:
		move_speed = 50
	else:
		move_speed = 55

func _physics_process(delta: float) -> void:
	if state == "dead":
		is_leaping = false
		is_attack4_leaping = false
		velocity = Vector2.ZERO

		attack1_hitbox.set_deferred("monitoring", false)
		attack2_hitbox.set_deferred("monitoring", false)
		attack3_hitbox.set_deferred("monitoring", false)

		super._physics_process(delta)
		return

	if is_attack4_leaping:
		velocity = leap_direction * leap_speed
		move_and_slide()
		return

	if is_leaping:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if state != "move":
		super._physics_process(delta)
		return

	if not is_active or player == null or player.is_dead:
		super._physics_process(delta)
		return

	player_distance = global_position.distance_to(player.global_position)
	player_direction = global_position.direction_to(player.global_position)
	sprite.flip_h = player_direction.x < 0

	if player_distance > attack_range and player_distance <= leap_range:
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_leap_time >= leap_cooldown:
			_try_leap_attack()
			return

	if player_distance <= attack_range:
		_try_attack()
		return

	super._physics_process(delta)

func _try_leap_attack():
	if state != "move" or player == null or player.is_dead:
		return

	last_leap_time = Time.get_ticks_msec() / 1000.0
	state = "attack"
	is_attack4_active = true
	attack4_cancelled = false
	velocity = Vector2.ZERO
	await attack4_move()
	is_attack4_active = false
	if state == "attack":
		state = "move"

func _try_attack():
	if state != "move" or is_leaping or is_attack4_leaping:
		return

	if not super._try_attack():
		return

	var attack_choice = randi() % 3

	if attack_choice == 0:
		await attack1_move()
	elif attack_choice == 1:
		await attack2_move()
	else:
		await attack3_move()

	if state != "dead":
		state = "move"

func attack1_move():
	if state == "dead":
		return

	sprite.play("attack")
	attack.pitch_scale = randf_range(0.8, 1.2)
	attack.play()

	await get_tree().create_timer(0.2).timeout

	if state == "dead":
		return

	attack.play()
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack1_hitbox.monitoring = false

	await get_tree().create_timer(0.15).timeout
	attack.play()
	await get_tree().create_timer(0.05).timeout
	if state == "dead":
		return
	
	attack.pitch_scale = randf_range(0.9, 1.1)
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack1_hitbox.monitoring = false

	await sprite.animation_finished

func attack2_move():
	if state == "dead":
		return

	sprite.play("attack2")
	attack2.pitch_scale = randf_range(0.8, 1.2)

	await get_tree().create_timer(0.8).timeout

	if state == "dead":
		return
	attack2.play()
	attack2_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack2_hitbox.monitoring = false

	if state == "dead":
		return

	await sprite.animation_finished

func attack3_move():
	if state == "dead":
		return

	sprite.play("attack3")
	is_leaping = true
	velocity = Vector2.ZERO

	attack3.pitch_scale = randf_range(0.8, 1.2)
	attack3.play()

	await get_tree().create_timer(1.1).timeout

	if state == "dead":
		is_leaping = false
		return

	camera.shake(20)

	attack3_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack3_hitbox.monitoring = false

	await sprite.animation_finished
	is_leaping = false

func attack4_move():
	if state == "dead" or player == null or player.is_dead:
		return

	sprite.play("attack4")
	await get_tree().create_timer(0.25).timeout
	if attack4_cancelled or state == "dead":
		return

	is_attack4_leaping = true
	var target_position = player.global_position
	leap_direction = (target_position - global_position).normalized()
	sprite.flip_h = leap_direction.x < 0
	await get_tree().create_timer(leap_duration).timeout
	if attack4_cancelled or state == "dead":
		is_attack4_leaping = false
		return

	attack3_hitbox.set_deferred("monitoring", true)
	camera.shake(15)
	velocity = Vector2.ZERO
	is_attack4_leaping = false
	await get_tree().create_timer(0.5).timeout
	if attack4_cancelled or state == "dead":
		attack3_hitbox.set_deferred("monitoring", false)
		return
	attack3_hitbox.set_deferred("monitoring", false)
	await get_tree().create_timer(0.8).timeout
	if attack4_cancelled or state == "dead":
		return

func _stop_attack4_leap():
	is_attack4_leaping = false
	if state != "dead":
		sprite.play("idle")

func take_damage(amount: int):
	if is_attack4_leaping:
		return

	if state == "dead":
		return

	if is_attack4_active:
		attack4_cancelled = true
		is_attack4_leaping = false
		velocity = Vector2.ZERO
		attack3_hitbox.set_deferred("monitoring", false)

	super.take_damage(amount)

func _on_attack1_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage_ignore_invul(attack_damage)

func _on_attack2_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		critical.play()
		_apply_attack_effects(body, 2.0)
		camera.shake(10)
		body.take_damage(attack_damage * 2)

func _on_attack3_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		critical.play()
		body.take_damage(attack_damage * 999999)
		_apply_attack_effects(body, 3.0)

func _apply_attack_effects(body, slow_duration = 3.0):
	if not body:
		return

	var knockback_dir = (body.global_position - global_position).normalized()
	var knockback_strength = 500

	body.knockback_velocity = knockback_dir * knockback_strength
	body.slow_timer = slow_duration
	body.slow_multiplier = 0.1

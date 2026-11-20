
extends Enemy

@onready var attack_hitbox = $AttackHitbox
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")

@export var circle_radius: float = 75.0
@export var circle_speed: float = 0.7
@export var circle_move_speed: float = 45.0

@export var min_lunge_delay: float = 2.0
@export var max_lunge_delay: float = 5.0

var charge_direction : Vector2
var is_charging : bool = false
var is_circling : bool = false

var circle_angle: float = 0.0
var lunge_timer: float = 0.0

func _ready() -> void:
	super()
	cur_hp = 1
	max_hp = 1
	move_speed = 85

	attack_damage = 1
	attack_range = 45
	attack_rate = 3
	
	apply_modifiers()
	
	hurt_pitch = [0.5, 0.8]
	death_pitch = [0.8, 1.2]
	despawn_pitch = [0.8, 1.2]
	
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

	circle_angle = randf_range(0.0, TAU)
	lunge_timer = randf_range(min_lunge_delay, max_lunge_delay)


func _physics_process(delta: float) -> void:
	if is_charging:
		if state == "dead" or state == "rooted":
			_stop_charge()
			return

		velocity = charge_direction * move_speed
		move_and_slide()
		return

	# Only circle while normally moving
	if is_circling and state == "move" and !player.is_dead:
		circle_angle += circle_speed * delta

		var target_position = player.global_position + Vector2(
			cos(circle_angle),
			sin(circle_angle)
		) * circle_radius

		var direction = global_position.direction_to(target_position)
		velocity = direction * circle_move_speed
		move_and_slide()

		lunge_timer -= delta

		if lunge_timer <= 0:
			_try_attack()

		return

	super._physics_process(delta)


func _try_attack() -> bool:
	if state == "dead" or player.is_dead:
		return false

	if Time.get_unix_time_from_system() - last_attack_time < attack_rate:
		return false

	state = "attack"
	last_attack_time = Time.get_unix_time_from_system()
	velocity = Vector2.ZERO

	is_circling = false

	_attack()
	return true


func _attack():
	if state == "dead":
		return
	
	state = "attack"
	velocity = Vector2.ZERO
	
	if state == "dead" or state == "rooted":
		return

	sprite.play("walk")
	await get_tree().create_timer(randf_range(min_lunge_delay, max_lunge_delay)).timeout

	if state == "dead" or state == "rooted" or player.is_dead:
		_stop_charge()
		return
	charge_direction = global_position.direction_to(player.global_position).normalized()
	is_charging = true
	move_speed = 120
	attack_hitbox.set_deferred("monitoring", true)
	sprite.play("attack")
	await get_tree().create_timer(0.2).timeout
	var charge_time = 0.4
	var elapsed = 0.0
	while elapsed < charge_time:
		if !is_charging or state == "dead" or state == "rooted":
			_stop_charge()
			return
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	_stop_charge()


func _stop_charge():
	is_charging = false
	attack_hitbox.set_deferred("monitoring", false)
	move_speed = 85

	if state != "dead":
		state = "move"
		
		is_circling = true
		lunge_timer = randf_range(min_lunge_delay, max_lunge_delay)

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(attack_damage)
		_stop_charge()


func die():
	is_charging = false
	is_circling = false

	despawn.pitch_scale = randf_range(despawn_pitch[0], despawn_pitch[1])
	despawn.play()
	sprite.play("despawn")

	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(0.6, 0.6), 0.5)
	await tween.finished

	died.emit()
	
	await despawn.finished
	queue_free()

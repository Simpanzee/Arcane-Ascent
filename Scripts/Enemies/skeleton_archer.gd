extends Enemy

@export var flee_range : float = 60
@export var flee_speed : float = 90
@export var idle_after_shot : float = 0.8
@export var arrow_scene : PackedScene

func _ready() -> void:
	super()
	cur_hp = 3
	max_hp = 3
	move_speed = 35

	attack_damage = 1
	attack_range = 130
	attack_rate = 2.5
	
	hurt_pitch = [0.5, 2]
	death_pitch = [0.5, 2]
	despawn_pitch = [0.8, 1.2]


func _physics_process(_delta: float) -> void:
	if is_active == false:
		return
		
	if state != "move":
		return

	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)

	sprite.flip_h = player_direction.x < 0

	if player_distance < flee_range:
		velocity = -player_direction * flee_speed
		sprite.play("move")
		move_and_slide()
		return

	if player_distance < attack_range:
		_try_attack()
		return

	velocity = player_direction * move_speed
	sprite.play("move")
	move_and_slide()


func _try_attack():
	if !super():
		return

	if state == "dead":
		return

	sprite.play("attack")
	await get_tree().create_timer(0.6).timeout
	
	# Keep So it STAYS DEAD
	if state == "dead":
		return

	attack.pitch_scale = randf_range(0.5, 2)
	attack.play()
	
	var arrow = arrow_scene.instantiate()
	arrow.global_position = global_position
	arrow.direction = player_direction
	get_tree().current_scene.add_child(arrow)

	await sprite.animation_finished

	if state == "dead":
		return

	sprite.play("idle")
	await get_tree().create_timer(idle_after_shot).timeout

	if state != "dead":
		state = "move"

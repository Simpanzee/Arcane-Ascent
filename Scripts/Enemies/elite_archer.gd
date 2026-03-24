extends Enemy

@export var flee_speed : float = 80
@export var idle_after_shot : float = 0.8
@export var ideal_min_range : float = 90
@export var ideal_max_range : float = 140
@export var arrow_scene : PackedScene
@export var sniper_scene : PackedScene
@export var strafe_speed : float = 60
var strafe_dir : int = 1

@onready var bow_draw = $BowDraw
@onready var bow_shoot = $BowShoot
@onready var shine = $BowShine


func _ready() -> void:
	super()
	cur_hp = 3
	max_hp = 3
	move_speed = 55

	attack_damage = 1
	attack_range = 140
	attack_rate = 3
	
	apply_modifiers()
	
	hurt_pitch = [0.8, 1]
	death_pitch = [0.8, 1]
	despawn_pitch = [0.8, 1.2]

func _physics_process(_delta: float) -> void:
	if not is_active:
		return

	if player == null or not is_instance_valid(player):
		return

	if player.is_dead:
		velocity = Vector2.ZERO
		sprite.play("idle")
		return

	if state != "move":
		return

	var separation: Vector2
	var move_dir: Vector2
	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	sprite.flip_h = player_direction.x < 0
	
	if state == "dead":
		return
		
	if player_distance < ideal_min_range:
		separation = get_separation_force() * separation_strength
		move_dir = (-player_direction + separation).normalized()
		velocity = move_dir * flee_speed * speed_multiplier
		sprite.play("move")
		move_and_slide()
		return

	if player_distance <= ideal_max_range:
		if state == "rooted":
			velocity = Vector2.ZERO
			sprite.play("idle")
		else:
			if randf() < 0.01:
				strafe_dir *= -1
	
			var strafe_vector = Vector2(-player_direction.y, player_direction.x) * strafe_dir
			separation = get_separation_force()
			move_dir = (strafe_vector + separation).normalized()
			
			velocity = move_dir * strafe_speed * speed_multiplier
			sprite.play("move")
			move_and_slide()
		_try_attack()
		return

	separation = get_separation_force() * separation_strength
	move_dir = (player_direction + separation).normalized()
	velocity = move_dir * move_speed * speed_multiplier
	sprite.play("move")
	move_and_slide()

func _try_attack():
	if state == "attack":
		return

	if !super():
		return

	if state == "dead":
		return
	
	if randf() < 0.3:
		await _attack2()
	else:
		await _attack()
	
	if state == "dead":
		return

	sprite.play("idle")
	await get_tree().create_timer(idle_after_shot).timeout

	if state != "dead":
		state = "move"
		
func _attack():
	sprite.play("attack")
	await get_tree().create_timer(0.2).timeout
	attack.pitch_scale = randf_range(0.8, 1.1)
	attack.play()

	await get_tree().create_timer(0.4).timeout
	
	if state == "dead":
		return

	shoot_arrow()
	await sprite.animation_finished
	
func _attack2():
	sprite.play("attack2")
	bow_draw.pitch_scale = randf_range(0.8, 1.1)
	bow_draw.play()
	await get_tree().create_timer(0.3).timeout
	shine.pitch_scale = randf_range(0.8, 1.1)
	shine.play()
	await get_tree().create_timer(0.7).timeout

	if state == "dead":
		return
	
	bow_shoot.pitch_scale = randf_range(0.8, 1.1)
	bow_shoot.play()
	var arrow = sniper_scene.instantiate()
	var spawn_offset = 15
	arrow.global_position = global_position + arrow.direction * spawn_offset
	
	var prediction_time = 0.05
	var predicted_pos = player.global_position + player.velocity * prediction_time
	var random_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
	arrow.direction = global_position.direction_to(predicted_pos + random_offset)
	
	get_tree().current_scene.add_child(arrow)
	await get_tree().create_timer(0.2).timeout
	
func shoot_arrow():
	var arrow = arrow_scene.instantiate()
	arrow.damage = attack_damage
	arrow.global_position = global_position
	var prediction_time = 0.03 
	var predicted_pos = player.global_position + player.velocity * prediction_time
	
	var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	arrow.direction = global_position.direction_to(predicted_pos + random_offset)
	
	get_tree().current_scene.add_child(arrow)

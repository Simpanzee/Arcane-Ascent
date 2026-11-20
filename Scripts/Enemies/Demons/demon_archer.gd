extends Enemy

@export var flee_speed : float = 55
@export var idle_after_shot : float = 0.8
@export var ideal_min_range : float = 80
@export var ideal_max_range : float = 110
@export var arrow_scene : PackedScene
@export var burst_scene : PackedScene
@export var strafe_speed : float = 45
var strafe_dir : int = 1

@onready var burst = $Burst

func _ready() -> void:
	super()
	cur_hp = 3
	max_hp = 3
	move_speed = 60

	attack_damage = 2
	attack_range = 120
	attack_rate = 3.5
	
	apply_modifiers()
	
	hurt_pitch = [0.8, 1]
	death_pitch = [0.8, 1]
	despawn_pitch = [0.8, 1.2]

func _process(_delta: float) -> void:
	if state == "dead":
		return

	var hp_percentage = float(cur_hp) / float(max_hp)

	if hp_percentage > 0.66:
		strafe_speed = 50
		move_speed = 60
	elif hp_percentage > 0.33:
		strafe_speed = 55
		move_speed = 75
	else:
		strafe_speed = 60
		move_speed = 85


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
	
	if randf() < 0.2:
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
	await get_tree().create_timer(0.2).timeout
	for i in range(3):
		if state == "dead":
			return
		sprite.play("attack2")
		burst.play()
		shoot_burst_arrow()
		await sprite.animation_finished

	if state == "dead":
		return
	state = "move"
	
func shoot_arrow():
	var arrow = arrow_scene.instantiate()
	arrow.damage = attack_damage
	arrow.global_position = global_position
	var prediction_time = 0.03 
	var predicted_pos = player.global_position + player.velocity * prediction_time
	
	var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	arrow.direction = global_position.direction_to(predicted_pos + random_offset)
	
	get_tree().current_scene.add_child(arrow)
	
func shoot_burst_arrow():
	var arrow = burst_scene.instantiate()
	arrow.damage = attack_damage / attack_damage
	arrow.global_position = global_position
	var prediction_time = 0.03 
	var predicted_pos = player.global_position + player.velocity * prediction_time
	
	var random_offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	arrow.direction = global_position.direction_to(predicted_pos + random_offset)
	
	get_tree().current_scene.add_child(arrow)

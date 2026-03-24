extends Enemy

@onready var attack1_hitbox = $Attack1Hitbox
@onready var attack2_hitbox = $Attack2Hitbox
@onready var attack3_hitbox = $Attack3Hitbox
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")
@onready var attack2 = $Attack2
@onready var critical = $Critical
@onready var block = $Block
@onready var block2 = $Block2
@onready var block3 = $Block3
@onready var block4 = $Block4
@onready var block5 = $Block5
@onready var block6 = $Block6

var invulnerable_block: bool = false
var block_chance: float = 0.6

func _ready() -> void:
	super()
	cur_hp = 10
	max_hp = 10
	move_speed = 25
	attack_damage = 4
	attack_range = 30
	attack_rate = 2.0
	
	apply_modifiers()
	
	hurt_pitch = [0.5, 1]
	death_pitch = [0.5, 1]
	despawn_pitch = [0.5, 1]

	attack1_hitbox.monitoring = false
	attack2_hitbox.monitoring = false
	attack3_hitbox.monitoring = false
	
	attack1_hitbox.body_entered.connect(_on_attack1_hitbox_body_entered)
	attack2_hitbox.body_entered.connect(_on_attack2_hitbox_body_entered)
	attack3_hitbox.body_entered.connect(_on_attack3_hitbox_body_entered)

func _physics_process(_delta: float) -> void:
	if self.name != "Knight":
		super._physics_process(_delta)
		return

	if state == "dead" or player == null or player.is_dead:
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	sprite.flip_h = player_direction.x < 0

	if state == "move" and player_distance <= attack_range:
		await _try_attack()
		return

	if state == "move":
		var separation = get_separation_force() * separation_strength
		var move_dir = (player_direction + separation).normalized()
		velocity = move_dir * move_speed * speed_multiplier
		move_and_slide()
		if sprite.animation != "move":
			sprite.play("move")
	elif state == "rooted":
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()

func take_damage(amount: int):
	if state == "dead":
		return
	
	if invulnerable_block or randf() < block_chance:
		await _play_block_animation()
		return
		
	super.take_damage(amount)

func _play_block_animation() -> void:
	state = "block"
	velocity = Vector2.ZERO
	sprite.play("block")
	var block_choice = randi() % 6
	match block_choice:
		0: block.play()
		1: block2.play()
		2: block3.play()
		3: block4.play()
		4: block5.play()
		5: block6.play()
	await get_tree().create_timer(0.5).timeout

	if state != "dead":
		state = "move"
		sprite.play("move")

func _try_attack():
	if !super._try_attack():
		return
	
	velocity = Vector2.ZERO
	state = "attack"

	var attack_choice = randi() % 3
	
	if attack_choice == 0:
		await attack1_move()
	elif attack_choice == 1:
		await attack2_move()
	else:
		await attack3_move()

	if state != "dead":
		state = "move"
		sprite.play("move")

func attack1_move():
	if state == "dead":
		return
	sprite.play("attack")
	attack.pitch_scale = randf_range(0.8, 1.2)
	attack.play()
	await get_tree().create_timer(0.4).timeout
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack1_hitbox.monitoring = false
	await sprite.animation_finished

func attack2_move():
	if state == "dead":
		return
	sprite.play("attack2")
	attack2.pitch_scale = randf_range(0.8, 1.2)
	attack2.play()
	await get_tree().create_timer(0.25).timeout
	attack2_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack2_hitbox.monitoring = false
	await sprite.animation_finished

func attack3_move():
	if state == "dead":
		return
	sprite.play("attack3")
	attack.pitch_scale = randf_range(0.8, 1.2)
	attack.play()
	await get_tree().create_timer(0.2).timeout
	attack3_hitbox.monitoring = true
	attack.play()
	await get_tree().create_timer(0.15).timeout
	attack3_hitbox.monitoring = false
	await get_tree().create_timer(0.2).timeout
	attack3_hitbox.monitoring = true
	attack.pitch_scale = randf_range(0.9, 1.1)
	attack.play()
	await get_tree().create_timer(0.15).timeout
	attack3_hitbox.monitoring = false
	await sprite.animation_finished

func _on_attack1_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player.take_damage(attack_damage)

func _on_attack2_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		if body.current_health < 4:
			body.take_damage(attack_damage)
		else:
			critical.play()
			_apply_attack_effects(body, 2.0)
			camera.shake(10)
			var dynamic_damage = body.current_health - 1
			body.take_damage(dynamic_damage)

func _on_attack3_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage_ignore_invul(attack_damage-2)

func _apply_attack_effects(body, slow_duration = 3.0):
	if not body:
		return
	var knockback_dir = (body.global_position - global_position).normalized()
	var knockback_strength = 500
	body.knockback_velocity = knockback_dir * knockback_strength
	body.slow_timer = slow_duration
	body.slow_multiplier = 0.1

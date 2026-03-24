extends Enemy

@onready var attack_hitbox = $AttackHitbox
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")
@onready var critical = $Critical
@onready var charge = $Charge

var charge_direction : Vector2
var is_charging : bool = false

func _ready() -> void:
	super()
	cur_hp = 1
	max_hp = 1
	move_speed = 50

	attack_damage = 9999999999
	attack_range = 80
	attack_rate = 3
	
	apply_modifiers()
	
	hurt_pitch = [0.5, 0.8]
	death_pitch = [0.8, 1.2]
	despawn_pitch = [0.8, 1.2]
	
	attack_hitbox.monitoring = false
	attack_hitbox.body_entered.connect(_on_attack_hitbox_body_entered)

func _physics_process(delta: float) -> void:
	if is_charging:
		if state == "dead" or state == "hurt" or state == "rooted":
			is_charging = false
			attack_hitbox.set_deferred("monitoring", false)
			return
		
		velocity = charge_direction * move_speed
		move_and_slide()
		return
	super._physics_process(delta)

func _try_attack():
	if !super._try_attack():
		return
		
	_attack()

func _attack():
	if state == "dead":
		return
	
	state = "attack"
	velocity = Vector2.ZERO
	
	sprite.play("idle")
	await get_tree().create_timer(0.25).timeout
	
	if state == "dead":
		return
	attack.play()
	attack.pitch_scale = randf_range(0.9, 1.1)
	for i in range(3):
		sprite.modulate = Color(1, 0.2, 0.2)
		await get_tree().create_timer(0.12).timeout
		sprite.modulate = Color(1, 1, 1)
		await get_tree().create_timer(0.08).timeout
	
	if state == "dead":
		return
	if state == "rooted":
		return
	
	charge_direction = global_position.direction_to(player.global_position).normalized()
	await get_tree().create_timer(0.05).timeout
	
	sprite.modulate = Color(1, 0, 0)
	sprite.play("attack")
	charge.play()
	charge.pitch_scale = randf_range(0.9, 1.1)
	await get_tree().create_timer(0.2).timeout
	sprite.modulate = Color(1, 1, 1)
	
	if state == "dead":
		return
	
	is_charging = true
	move_speed = 300
	attack_hitbox.monitoring = true
	
	var charge_time = 0.4
	var elapsed = 0.0
	
	while elapsed < charge_time:
		if !is_charging or state == "dead" or state == "rooted":
			return
		await get_tree().process_frame
		elapsed += get_process_delta_time()
	
	if state != "dead":
		is_charging = false
		attack_hitbox.monitoring = false
		move_speed = 0
		sprite.play("idle")
		await get_tree().create_timer(2.0).timeout
		move_speed = 50
		if state != "dead":
			state = "move"

func _on_attack_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(attack_damage)
		critical.play()
		
		is_charging = false
		attack_hitbox.set_deferred("monitoring", false)
		velocity = Vector2.ZERO
		
		move_speed = 0
		sprite.play("idle")
		
		await get_tree().create_timer(2.0).timeout
		
		if state != "dead":
			move_speed = 50
			state = "move"

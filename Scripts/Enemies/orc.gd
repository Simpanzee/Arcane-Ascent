extends Enemy

@onready var attack1_hitbox = $Attack1Hitbox
@onready var attack2_hitbox = $Attack2Hitbox
@onready var attack3_hitbox = $Attack3Hitbox

@onready var attack2 = $Attack2
@onready var attack3 = $Attack3

func _ready() -> void:
	super()
	cur_hp = 4
	max_hp = 4
	move_speed = 25

	attack_damage = 3
	attack_range = 30
	attack_rate = 1.5
	
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
	
func _try_attack():
	if !super():
		return
	
	var attack_choice = randi() % 3
	
	if attack_choice == 0:
		await attack1_move()
	elif attack_choice == 1:
		await attack2_move()
	else:
		await attack3_move()

	state = "move"
	
func attack1_move():
	sprite.play("attack")
	attack.pitch_scale = randf_range(0.8, 1.2)
	
	if state == "dead":
		return
		
	attack.play()
	await get_tree().create_timer(0.25).timeout
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack1_hitbox.monitoring = false
	await sprite.animation_finished


func attack2_move():
	sprite.play("attack2")
	attack2.pitch_scale = randf_range(0.8, 1.2)
	
	if state == "dead":
		return
		
	attack2.play()
	await get_tree().create_timer(0.35).timeout
	attack2_hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack2_hitbox.monitoring = false
	await sprite.animation_finished


func attack3_move():
	sprite.play("attack3")
	attack3.pitch_scale = randf_range(0.8, 1.2)
	
	if state == "dead":
		return
		
	attack3.play()
	await get_tree().create_timer(0.3).timeout
	attack3_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack3_hitbox.monitoring = false
	await sprite.animation_finished

func _on_attack1_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player.take_damage(attack_damage)

func _on_attack2_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player.take_damage(attack_damage)

func _on_attack3_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player.take_damage(attack_damage)

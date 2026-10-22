extends Enemy

@onready var attack1_hitbox = $Attack1Hitbox
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")

func _ready() -> void:
	super()
	cur_hp = 2
	max_hp = 2
	move_speed = 55

	attack_damage = 2
	attack_range = 26
	attack_rate = 1.7
	
	apply_modifiers()
	
	hurt_pitch = [1.2, 1.5]
	death_pitch = [1.5, 1.8]
	despawn_pitch = [0.8, 1.2]
	
	attack1_hitbox.monitoring = false
	attack1_hitbox.body_entered.connect(_on_attack1_hitbox_body_entered)
	
func _try_attack():
	if !super():
		return
		
	await attack_move()

	if state != "dead":
		state = "move"
	
func attack_move():
	if state == "dead":
		return
	
	var attack_choice = randi_range(0, 1)
	
	if attack_choice == 0:
		sprite.play("attack")
	else:
		sprite.play("attack2")
		
	attack.pitch_scale = randf_range(0.8, 1.2)
	if state == "dead":
		return
	attack.play()
	await get_tree().create_timer(0.2).timeout
	
	if state == "dead":
		return
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	
	attack1_hitbox.monitoring = false
	if state == "dead":
		return
	await sprite.animation_finished

func _on_attack1_hitbox_body_entered(body):
	if body.is_in_group("Player"):
		player.take_damage(attack_damage)

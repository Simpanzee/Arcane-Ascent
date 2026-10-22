extends Enemy

@onready var attack1_hitbox = $Attack1Hitbox
@onready var attack2_hitbox = $Attack2Hitbox
@onready var laugh = $Laugh
@onready var attack2 = $Attack2
@onready var critical = $Critical

@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")

@export var teleport_range: float = 120.0
@export var teleport_chance: float = 0.15
@export var teleport_cooldown: float = 7.0
@export var activation_delay: float = 3.0

var enemy_activated: bool = false
var activation_timer_started: bool = false
var can_teleport: bool = true
var teleporting: bool = false

func _ready() -> void:
	super()
	cur_hp = 5
	max_hp = 5
	move_speed = 50

	attack_damage = 2
	attack_range = 45
	attack_rate = 1.7
		
	apply_modifiers()
	
	hurt_pitch = [0.6, 1.0]
	death_pitch = [0.8, 1.2]
	despawn_pitch = [0.8, 1.2]
	
	attack1_hitbox.monitoring = false
	attack1_hitbox.body_entered.connect(_on_attack1_hitbox_body_entered)
	attack2_hitbox.monitoring = false

	
func _try_attack():
	if teleporting or state == "dead" or state == "rooted":
		return false

	if !super():
		return false

	await attack1_move()
	if state != "dead" and not teleporting:
		state = "move"

	return true

func _physics_process(delta: float) -> void:
	if teleporting:
		if state == "rooted" or state == "dead":
			teleporting = false
			super._physics_process(delta)
			return

		velocity = Vector2.ZERO
		move_and_slide()
		return
	super._physics_process(delta)

func _process(_delta: float) -> void:
	if state == "rooted" or state == "dead":
		return

	if player == null:
		return

	if not activation_timer_started:
		activation_timer_started = true
		await get_tree().create_timer(activation_delay).timeout

		if state == "dead" or state == "rooted":
			return

		enemy_activated = true

	if not enemy_activated:
		return

	if state != "move":
		return

	if teleporting or not can_teleport:
		return

	var distance = global_position.distance_to(player.global_position)

	if distance <= teleport_range:
		if randf() < teleport_chance:
			teleport_to_player()

func teleport_to_player() -> void:
	if not is_active or teleporting or not can_teleport:
		return

	if state == "dead" or state == "rooted":
		return

	if player == null:
		return

	teleporting = true
	can_teleport = false
	velocity = Vector2.ZERO
	state = "attack"

	sprite.play("attack3_1")
	await sprite.animation_finished
	
	if not is_active or state == "dead" or state == "rooted":
		teleporting = false
		can_teleport = true
		return
	
	if state == "dead":
		teleporting = false
		return

	if state == "rooted":
		teleporting = false
		can_teleport = true
		return

	var direction = (global_position - player.global_position).normalized()
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	global_position = player.global_position + direction * 25.0
	
	if state == "dead":
		return
	sprite.play("attack3_2")
	attack2.play()

	attack.pitch_scale = randf_range(0.8, 1.2)
	
	if state == "dead":
		return
		
	await get_tree().create_timer(0.1).timeout
	await get_tree().create_timer(0.3).timeout
	
	if state == "dead":
		return
	attack2_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	
	attack2_hitbox.monitoring = false
	if state == "dead":
		return
	
	await sprite.animation_finished
	teleporting = false
	state = "move"

	await get_tree().create_timer(teleport_cooldown).timeout

	if state != "dead":
		can_teleport = true

func take_damage(amount: int) -> void:
	if teleporting or state == "dead":
		return

	super.take_damage(amount)
	
func attack1_move():
	if state == "dead":
		return
	sprite.play("attack")
	attack.pitch_scale = randf_range(0.8, 1.2)
	
	if state == "dead":
		return
	await get_tree().create_timer(0.1).timeout
	attack.play()
	await get_tree().create_timer(0.3).timeout
	
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
		cur_hp = min(cur_hp + 1, max_hp)
		healthChanged.emit()
			
func _on_attack2_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		laugh.pitch_scale = randf_range(0.8, 1.1)
		laugh.play()
		critical.play()
		player.take_damage(attack_damage * 2)
		cur_hp = max_hp
		healthChanged.emit()
			

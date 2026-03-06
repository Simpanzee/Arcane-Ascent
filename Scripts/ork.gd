extends CharacterBody2D

@export var cur_hp : int = 10
@export var max_hp : int = 10
@export var move_speed : float = 20

@export var attack_damage : int = 1
@export var attack_range : float = 30
@export var attack_rate : float = 1.5
var last_attack_time : float

@export var separation_radius : float = 20
@export var separation_strength : float = 80

@onready var sprite = $AnimatedSprite2D

@onready var attack1_hitbox = $Attack1Hitbox
@onready var attack2_hitbox = $Attack2Hitbox
@onready var attack3_hitbox = $Attack3Hitbox

@onready var orc_attack1 = $OrcAttack1
@onready var orc_attack2 = $OrcAttack2
@onready var orc_attack3 = $OrcAttack3
@onready var orc_hurt = $OrcHurt
@onready var orc_death = $OrcDeath
@onready var despawn = $Despawn

var room : Room
var is_active : bool = false
var player : CharacterBody2D

var player_direction : Vector2
var player_distance : float

var state : String = "move"

signal died

func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
	add_to_group("Enemy")
	
	attack1_hitbox.monitoring = false
	attack2_hitbox.monitoring = false
	attack3_hitbox.monitoring = false
	
	attack1_hitbox.body_entered.connect(_on_attack1_hitbox_body_entered)
	attack2_hitbox.body_entered.connect(_on_attack2_hitbox_body_entered)
	attack3_hitbox.body_entered.connect(_on_attack3_hitbox_body_entered)

func _initialize(_in_room : Room):
	pass

func _physics_process(_delta: float) -> void:
	if is_active == false:
		return
		
	if state != "move":
		return
		
	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	
	sprite.flip_h = player_direction.x < 0
	
	if player_distance < attack_range:
		_try_attack()
		return
	
	var separation = get_separation_force() * separation_strength
	var move_dir = (player_direction + separation).normalized()
	velocity = move_dir * move_speed
	
	sprite.play("move")
	move_and_slide()


func get_separation_force() -> Vector2:
	var force := Vector2.ZERO
	
	for body in get_tree().get_nodes_in_group("Enemy"):
		if body == self:
			continue
			
		var dist = global_position.distance_to(body.global_position)
		
		if dist < separation_radius and dist > 0:
			var push_dir = body.global_position.direction_to(global_position)
			var strength = (separation_radius - dist) / separation_radius
			force += push_dir * strength
			
	return force

func _try_attack():
	if state == "dead":
		return

	if Time.get_unix_time_from_system() - last_attack_time < attack_rate:
		return
	
	state = "attack"
	last_attack_time = Time.get_unix_time_from_system()
	velocity = Vector2.ZERO
	
	var attack_choice = randi() % 3
	
	if attack_choice == 0:
		await attack1()
	elif attack_choice == 1:
		await attack2()
	else:
		await attack3()

	state = "move"


func attack1():
	sprite.play("attack")
	orc_attack1.pitch_scale = randf_range(0.8, 1.2)
	orc_attack1.play()
	await get_tree().create_timer(0.25).timeout
	attack1_hitbox.monitoring = true
	await get_tree().create_timer(0.15).timeout
	attack1_hitbox.monitoring = false
	await sprite.animation_finished


func attack2():
	sprite.play("attack2")
	orc_attack2.pitch_scale = randf_range(0.8, 1.2)
	orc_attack2.play()
	await get_tree().create_timer(0.35).timeout
	attack2_hitbox.monitoring = true
	await get_tree().create_timer(0.2).timeout
	attack2_hitbox.monitoring = false
	await sprite.animation_finished


func attack3():
	sprite.play("attack3")
	orc_attack3.pitch_scale = randf_range(0.8, 1.2)
	orc_attack3.play()
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


func take_damage(amount : int):
	if is_active == false:
		return
		
	if state == "dead":
		return
		
	state = "hurt"
	velocity = Vector2.ZERO
	
	sprite.play("hurt")
	orc_hurt.pitch_scale = randf_range(0.5, 0.8)
	orc_hurt.play()
	
	cur_hp -= amount
	
	await sprite.animation_finished
	
	if cur_hp <= 0:
		sprite.play("death")
		orc_death.pitch_scale = randf_range(0.8, 1.2)
		orc_death.play()
		state = "dead"
		await sprite.animation_finished
		
		sprite.scale = Vector2(0.6, 0.6)
		sprite.play("despawn")
		despawn.pitch_scale = randf_range(0.8, 1.2)
		despawn.play()
		await sprite.animation_finished
		
		die()
	else:
		state = "move"


func die():
	died.emit()
	queue_free()

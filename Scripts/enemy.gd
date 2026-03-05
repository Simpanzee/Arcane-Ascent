extends CharacterBody2D

@export var cur_hp : int = 4
@export var max_hp : int = 4
@export var move_speed : float = 20

@export var attack_damage : int = 1
@export var attack_range : float = 15
@export var attack_rate 	: float = 1.5
var last_attack_time : float

@onready var sprite = $AnimatedSprite2D
@onready var slime_attack = $SlimeAttack
@onready var slime_death = $SlimeDeath
@onready var slime_hurt = $SlimeHurt
@onready var despawn = $Despawn

var room : Room
var is_active : bool = false
var player : CharacterBody2D

var player_direction : Vector2
var player_distance : float

var state : String = "move"

func  _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	
func _initialize (_in_room : Room):
	pass
	
func _physics_process(_delta: float) -> void:
	if state != "move":
		return
		
	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	
	sprite.flip_h = player_direction.x < 0
	
	if player_distance < attack_range:
		_try_attack()
		return
	
	velocity = player_direction * move_speed
	sprite.play("move")
	move_and_slide()
	
func _try_attack():
	if state == "dead":
		return

	if Time.get_unix_time_from_system() - last_attack_time < attack_rate:
		return
	
	state = "attack"
	last_attack_time = Time.get_unix_time_from_system()
	velocity = Vector2.ZERO
	sprite.play("attack")

	
	await get_tree().create_timer(0.3).timeout

	slime_attack.pitch_scale = randf_range(0.5, 2)
	slime_attack.play()
	if state == "dead":
		return
	
	player.take_damage(attack_damage)
	state = "move"
	
func take_damage(amount : int):
	if state == "dead":
		return
		
	state = "hurt"
	velocity = Vector2.ZERO
	sprite.play("hurt")
	
	slime_hurt.pitch_scale = randf_range(0.5, 2)
	slime_hurt.play()
	
	cur_hp -= amount
	await sprite.animation_finished
	
	if cur_hp <= 0:
		sprite.play("death")
		state = "dead"
		slime_death.pitch_scale = randf_range(0.5, 2)
		slime_death.play()
		await sprite.animation_finished
		
		despawn.pitch_scale = randf_range(0.8, 1.2)
		despawn.play()
		sprite.scale = Vector2(0.6, 0.6)
		sprite.play("despawn")
		await sprite.animation_finished
		die()
	else:
		state = "move"
func die():
	queue_free()

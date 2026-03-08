extends CharacterBody2D
class_name Enemy

@export var cur_hp : int
@export var max_hp : int
@export var move_speed : float

@export var attack_damage : int
@export var attack_range : float
@export var attack_rate : float
var last_attack_time : float

@export var separation_radius : float = 20
@export var separation_strength : float = 80

@onready var sprite = $AnimatedSprite2D
@onready var attack = $Attack
@onready var death = $Death
@onready var hurt = $Hurt
@onready var despawn = $Despawn

var hurt_pitch : Array[float]
var death_pitch : Array[float]
var despawn_pitch : Array[float]

var is_active : bool = false
var player : CharacterBody2D

var player_direction : Vector2
var player_distance : float

var state : String = "move"
var speed_multiplier : float = 1.0

signal died
signal healthChanged

func _ready() -> void:
	add_to_group("Enemy")
	player = get_tree().get_first_node_in_group("Player")

func _physics_process(_delta: float) -> void:
	if is_active == false:
		return
	
	if player == null or player.is_dead:
		state = "idle"
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	player_direction = global_position.direction_to(player.global_position)
	player_distance = global_position.distance_to(player.global_position)
	sprite.flip_h = player_direction.x < 0

	if state == "dead":
		return

	if player_distance < attack_range:
		_try_attack()
		return

	if state == "rooted":
		velocity = Vector2.ZERO
		sprite.play("idle")
		move_and_slide()
		return

	if state != "move":
		return

	var separation = get_separation_force() * separation_strength
	var move_dir = (player_direction + separation).normalized()
	velocity = move_dir * move_speed * speed_multiplier
	sprite.play("move")
	move_and_slide()


func _try_attack() -> bool:
	if state == "dead" or player.is_dead:
		return false

	if Time.get_unix_time_from_system() - last_attack_time < attack_rate:
		return false
	
	state = "attack"
	last_attack_time = Time.get_unix_time_from_system()
	velocity = Vector2.ZERO
	
	return true


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


func take_damage(amount : int):
	if is_active == false:
		return
	
	if state == "dead":
		return
		
	state = "hurt"
	velocity = Vector2.ZERO
	
	sprite.play("hurt")
	hurt.pitch_scale = randf_range(hurt_pitch[0], hurt_pitch[1])
	hurt.play()
	
	cur_hp -= amount
	healthChanged.emit()
	
	await sprite.animation_finished
	
	if cur_hp <= 0:
		die()
	else:
		state = "move"

func apply_root_slow():
	state = "rooted"
	speed_multiplier = 0.0

func remove_root_slow():
	speed_multiplier = 1.0
	if state == "rooted":
		state = "move"

var has_died: bool = false

func die():
	if has_died:
		return
	
	has_died = true
	sprite.play("death")
	state = "dead"
   
	death.pitch_scale = randf_range(death_pitch[0], death_pitch[1])
	death.play()
   
	await sprite.animation_finished
	await get_tree().create_timer(1).timeout
   
	despawn.pitch_scale = randf_range(despawn_pitch[0], death_pitch[1])
	despawn.play()
   
	sprite.play("despawn")
	sprite.scale = Vector2(0.6, 0.6)

	await sprite.animation_finished
   
	died.emit()
	queue_free()

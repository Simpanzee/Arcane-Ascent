extends CharacterBody2D

@export var move_speed : float = 300
@export var cast_time : float = 1.5
@export var current_health : int = 3
@export var max_health : int = 3

@onready var fire_sound = $FireSound
@onready var walk_sound = $WalkSound 
@onready var ultimate_sound = $UltimateSound
@onready var blink_sound = $BlinkSound
@onready var root_start = $RootStart
@onready var root_end = $RootEnd

@onready var hurt = $Hurt
@onready var death_1 = $Death1
@onready var death_2 = $Death2
@onready var death_3 = $Death3

var projectile_scene : PackedScene = preload("res://Scenes/Spells/projectile.tscn")
var beam_scene : PackedScene = preload("res://Scenes/Spells/beam.tscn")
var blink_scene : PackedScene = preload("res://Scenes/Spells/blink.tscn")
var roots_scene : PackedScene = preload("res://Scenes/Spells/roots.tscn")

@onready var sprite = $AnimatedSprite2D
@onready var cast_timer = $CastTimer

var is_casting : bool = false
var is_invulnerable : bool = false
var invuln_time : float = 2.0
var is_dead : bool = false


func _physics_process(_delta: float) -> void:
	if is_casting:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	var move_input : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_input * move_speed
		
	if move_input == Vector2.ZERO:
		if sprite.animation != "idle":
			sprite.play("idle")
		if walk_sound.playing:
			walk_sound.stop()
	else:
		if sprite.animation != "walk":
			sprite.play("walk")
		if not walk_sound.playing:
			walk_sound.play()
	
	move_and_slide()

func _process(_delta: float) -> void:
	if is_casting:
		return
	
	var mouse_pos : Vector2 = get_global_mouse_position()
	var mouse_dir : Vector2 = (mouse_pos - global_position).normalized()
	
	sprite.flip_h = mouse_dir.x < 0
	
	if Input.is_action_just_pressed("shoot"):
		start_cast(mouse_pos, mouse_dir)
	
	if Input.is_action_just_pressed("blink"):
		blink()
	
	if Input.is_action_just_pressed("root"):
		cast_root()
	
	if Input.is_action_just_pressed("ultimate"):
		start_ultimate(mouse_pos, mouse_dir)

func take_damage(amount : int):
	if is_dead or is_invulnerable:
		return

	current_health -= amount
	hurt.pitch_scale = randf_range(1, 1.4)
	hurt.play()
	print("Ouch! HP:", current_health)

	if current_health <= 0:
		if is_invulnerable:
			current_health = 1
			return
		die()
		return

	is_invulnerable = true
	is_casting = true

	sprite.play("hurt")
	await sprite.animation_finished
	start_invulnerability()
	is_casting = false

func start_cast(_mouse_pos: Vector2, mouse_dir: Vector2) -> void:
	is_casting = true
	velocity = Vector2.ZERO
	sprite.play("cast")
	
	await get_tree().create_timer(0.3).timeout
	shoot(mouse_dir)
	await sprite.animation_finished
	
	is_casting = false

func cast_root():
	is_casting = true
	sprite.play("blink_cast")
	await sprite.animation_finished
	is_casting = false
	var cast_point = get_global_mouse_position()
	var root_radius = 40.0
	var affected = false
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy.global_position.distance_to(cast_point) <= root_radius:
			var root = roots_scene.instantiate()
			enemy.add_child(root)
			root.position = Vector2.ZERO
			affected = true
	if affected:
		root_start.pitch_scale = randf_range(0.95, 1.1)
		root_start.play()
	await get_tree().create_timer(3).timeout
	if affected:
		root_end.pitch_scale = randf_range(0.95, 1.1)
		root_end.play()

func start_ultimate(_mouse_pos: Vector2, mouse_dir: Vector2) -> void:
	is_invulnerable = true
	is_casting = true
	velocity = Vector2.ZERO
	
	sprite.play("ultimate")
	ultimate_sound.play()
	
	await get_tree().create_timer(2.0).timeout
	var beam = beam_scene.instantiate()
	get_tree().current_scene.add_child(beam)
	
	var spawn_offset = 85
	var current_angle = mouse_dir.angle()
	var rotate_speed = 0.5
	var ultimate_duration = 2.0
	var timer = 0.0
	
	while timer < ultimate_duration:
		await get_tree().process_frame
		var delta = get_process_delta_time()
		
		var mouse_pos = get_global_mouse_position()
		var target_dir = (mouse_pos - global_position).normalized()
		var target_angle = target_dir.angle()
		
		current_angle = lerp_angle(current_angle, target_angle, rotate_speed * delta)
		
		var dir = Vector2.RIGHT.rotated(current_angle)
		
		beam.rotation = current_angle + deg_to_rad(90)
		beam.global_position = global_position + dir * spawn_offset
		
		timer += delta
	
	await beam.finished
	is_invulnerable = false
	is_casting = false

func _on_CastTimer_timeout() -> void:
	is_casting = false

func shoot(mouse_dir: Vector2) -> void:
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var spawn_offset = 20

	projectile.direction = mouse_dir
	projectile.global_position = global_position + (mouse_dir * spawn_offset)
	projectile.rotation = mouse_dir.angle()
	
	fire_sound.pitch_scale = randf_range(0.8, 1.2)
	fire_sound.play()

func blink() -> void:
	if is_casting:
		return
	is_casting = true
	velocity = Vector2.ZERO

	if walk_sound.playing:
		walk_sound.stop()

	sprite.play("blink_cast")
	await sprite.animation_finished

	blink_sound.pitch_scale = randf_range(0.8, 1.2)
	blink_sound.play()

	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	var blink_distance = 150
	var blink_speed = 2000

	var distance_moved = 0.0
	while distance_moved < blink_distance:
		await get_tree().process_frame
		var delta = get_process_delta_time()
		var step = blink_speed * delta
		if distance_moved + step > blink_distance:
			step = blink_distance - distance_moved
		var collision = move_and_collide(direction * step)
		if collision:
			break

		distance_moved += step

	var blink_effect = blink_scene.instantiate()
	blink_effect.global_position = global_position
	get_tree().current_scene.add_child(blink_effect)

	await get_tree().process_frame
	await get_tree().create_timer(0.5).timeout

	is_casting = false

func start_invulnerability():
	var blink_speed = 0.05
	var elapsed = 0.0

	while elapsed < invuln_time:
		sprite.visible = false
		await get_tree().create_timer(blink_speed).timeout
		
		sprite.visible = true
		await get_tree().create_timer(blink_speed).timeout
		
		elapsed += blink_speed * 2

	sprite.visible = true
	is_invulnerable = false
	
func die():	
	is_dead = true
	is_casting = true
	
	var death_choice = randi() % 3
	
	if death_choice == 0:
		death_1.pitch_scale = randf_range(0.9, 1.2)
		death_1.play()
	elif death_choice == 1:
		death_2.pitch_scale = randf_range(0.9, 1.2)
		death_2.play()
	else:
		death_3.pitch_scale = randf_range(0.9, 1.2)
		death_3.play()
		
	sprite.play("death")
	await get_tree().create_timer(2).timeout
	print("Player died")

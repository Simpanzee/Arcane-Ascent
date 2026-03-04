extends CharacterBody2D

@export var move_speed : float = 100
var projectile_scene : PackedScene = preload("res://Scenes/projectile.tscn")

@onready var sprite : Sprite2D = $Sprite2D

func _physics_process(delta: float) -> void:
	var move_input : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = move_input * move_speed
	move_and_slide()
	
func _process(delta: float) -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var mouse_dir : Vector2 = (mouse_pos - global_position).normalized()
	
	sprite.flip_h = mouse_dir.x < 0
	if Input.is_action_pressed("shoot"):
		shoot(mouse_pos, mouse_dir)
	
func shoot(mouse_pos, mouse_dir) -> void:
	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = global_position
	projectile.direction = mouse_dir

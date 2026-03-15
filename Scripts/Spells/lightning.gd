extends Area2D

@export var hits : int = 3
@export var interval : float = 0.4
@export var damage : int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var radius_hitbox: Area2D = $AOE
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")

var enemies_in_range : Array = []

func _ready():
	radius_hitbox.monitoring = true
	radius_hitbox.body_entered.connect(_on_body_entered)
	radius_hitbox.body_exited.connect(_on_body_exited)

	await get_tree().physics_frame
	for body in radius_hitbox.get_overlapping_bodies():
		_on_body_entered(body)

	for i in range(hits):
		sprite.play("strike")
		await _wait_for_frame(5)
		for enemy in enemies_in_range:
			if enemy and enemy.is_inside_tree() and enemy.has_method("take_damage"):
				camera.shake(8)
				enemy.take_damage(damage)

		await get_tree().create_timer(interval).timeout
	await sprite.animation_finished
	queue_free()

func _wait_for_frame(frame_index: int) -> void:
	while sprite.frame != frame_index:
		await get_tree().physics_frame

func _on_body_entered(body: Node2D):
	if !body.is_in_group("Enemy"):
		return
	if body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D):
	enemies_in_range.erase(body)

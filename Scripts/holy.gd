
extends Area2D

@export var damage: int = 2
@export var damage_delay: float = 0.5

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var activated: bool = false

func _ready() -> void:
	monitoring = true
	sprite.play("default")
	_apply_damage_after_delay()


func _apply_damage_after_delay() -> void:
	await get_tree().create_timer(damage_delay).timeout

	if not is_inside_tree():
		return

	activated = true

	for body in get_overlapping_bodies():
		if not is_instance_valid(body):
			continue

		if body.is_in_group("Player") and not body.is_dead:
			if body.has_method("take_damage"):
				body.take_damage(damage)

	queue_free()

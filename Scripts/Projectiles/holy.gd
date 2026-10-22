
extends Area2D

@export var damage_delay: float = 0.3
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
				_apply_attack_effects(body, 2.0)

	queue_free()
	
func _apply_attack_effects(body, slow_duration = 3.0):
	if not body:
		return
	var knockback_dir = (body.global_position - global_position).normalized()
	var knockback_strength = 100
	body.knockback_velocity = knockback_dir * knockback_strength
	body.slow_timer = slow_duration
	body.slow_multiplier = 0.4


extends Area2D

@export var heal_amount: int = 1
@export var active_time: float = 0.8

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	# This effect must be a child of the enemy being healed.
	var enemy = get_parent()

	if not enemy is Enemy:
		queue_free()
		return

	if enemy.state == "dead":
		queue_free()
		return

	# Center the effect on the enemy, like the roots spell.
	position = Vector2.ZERO

	if sprite:
		sprite.play("default")

	# Heal immediately when the effect appears.
	if enemy.cur_hp < enemy.max_hp:
		enemy.cur_hp = mini(enemy.cur_hp + heal_amount, enemy.max_hp)
		enemy.healthChanged.emit()

	# Keep the animation visible briefly.
	await get_tree().create_timer(active_time).timeout

	if is_instance_valid(self):
		queue_free()

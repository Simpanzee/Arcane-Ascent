extends Area2D

signal finished

@export var active_time : float = 2.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2

func _ready() -> void:
	rotation = direction.angle()
	
	sprite.play("start")
	await sprite.animation_finished

	sprite.play("active")
	await get_tree().create_timer(active_time).timeout

	sprite.play("end")
	await sprite.animation_finished

	emit_signal("finished")
	queue_free()

extends Area2D

@export var active_time : float = 2.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2

func _ready() -> void:
	
	sprite.play("default")
	await sprite.animation_finished

	await get_tree().create_timer(active_time).timeout

	sprite.play("end")
	await sprite.animation_finished

	queue_free()

extends Area2D

@export var active_time : float = 2.0
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:	
	sprite.play("default")
	await sprite.animation_finished
	queue_free()

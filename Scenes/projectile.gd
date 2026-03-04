extends Area2D

@export var base_speed : float = 100
var direction : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	despawn()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	global_position += direction * base_speed * delta

func despawn() -> void:
	await get_tree().create_timer(3).timeout
	queue_free()

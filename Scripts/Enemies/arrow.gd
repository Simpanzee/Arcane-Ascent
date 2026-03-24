extends Area2D

@export var base_speed : float = 250
@onready var hit = $Hit

var damage : int

var direction: Vector2
var is_traveling: bool = false

func _ready() -> void:
	rotation = direction.angle()
	is_traveling = true
	despawn()
	
func _process(delta: float) -> void:
	if is_traveling:
		global_position += direction * base_speed * delta

func despawn() -> void:
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		hit.play()
		body.take_damage(damage)
		$Sprite2D.visible = false
		is_traveling = false
		await get_tree().create_timer(hit.stream.get_length()).timeout
		queue_free()

	

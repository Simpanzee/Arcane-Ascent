extends Area2D

@export var base_speed : float = 200
@export var damage : int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var direction: Vector2
var is_traveling: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rotation = direction.angle()
	sprite.play("fire")
	
	await sprite.animation_finished
	sprite.play("traveling")
	is_traveling = true
	despawn()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_traveling:
		global_position += direction * base_speed * delta

func despawn() -> void:
	await get_tree().create_timer(1.0).timeout

	is_traveling = false
	sprite.play("hit_miss")

	await sprite.animation_finished
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		
		sprite.play("hit_miss")
		await sprite.animation_finished
		queue_free()
	
	

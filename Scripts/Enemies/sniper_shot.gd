extends Area2D

@export var base_speed : float = 425
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")
@onready var hit = $Hit
@onready var critical = $Critical

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
		if body.current_health <= 1:
			body.take_damage(1)
		else:
			critical.play()
			_apply_attack_effects(body, 2.0)
			camera.shake(10)
			var dynamic_damage = body.current_health - 1
			body.take_damage(dynamic_damage)
		$Sprite2D.visible = false
		is_traveling = false
		await get_tree().create_timer(hit.stream.get_length()).timeout
		queue_free()

func _apply_attack_effects(body, slow_duration = 3.0):
	if not body:
		return
	var knockback_dir = (body.global_position - global_position).normalized()
	var knockback_strength = 500
	body.knockback_velocity = knockback_dir * knockback_strength
	body.slow_timer = slow_duration
	body.slow_multiplier = 0.1
	

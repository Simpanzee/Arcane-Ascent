extends Area2D

@export var hits : int = 3
@export var interval : float = 0.5
@export var damage : int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var radius_hitbox: Area2D = $AOE

@onready var lightning_sound1 = $Lightning1
@onready var lightning_sound2 = $Lightning2
@onready var lightning_sound3 = $Lightning3

var enemies_in_range : Array = []

func _ready():

	radius_hitbox.monitoring = true
	radius_hitbox.body_entered.connect(_on_body_entered)
	radius_hitbox.body_exited.connect(_on_body_exited)

	await get_tree().physics_frame

	for body in radius_hitbox.get_overlapping_bodies():
		_on_body_entered(body)

	sprite.play("strike")
	await sprite.animation_finished

	if enemies_in_range.is_empty():
		queue_free()
		return

	for i in range(hits):
		sprite.play("strike")
		var sound = randi() % 3
		if sound == 0:
			lightning_sound1.pitch_scale = randf_range(0.9, 1.2)
			lightning_sound1.play()
		elif sound == 1:
			lightning_sound2.pitch_scale = randf_range(0.9, 1.2)
			lightning_sound2.play()
		else:
			lightning_sound3.pitch_scale = randf_range(0.9, 1.2)
			lightning_sound3.play()

		for enemy in enemies_in_range:
			if enemy and enemy.is_inside_tree():
				if enemy in radius_hitbox.get_overlapping_bodies():
					if enemy.has_method("take_damage"):
						enemy.take_damage(damage)

		await get_tree().create_timer(interval).timeout
		
	await sprite.animation_finished


func _on_body_entered(body: Node2D):
	if !body.is_in_group("Enemy"):
		return

	if body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D):
	enemies_in_range.erase(body)

extends Area2D

@export var hits : int = 3
@export var interval : float = 0.5
@export var damage : int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var radius_hitbox: Area2D = $AOE

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
		await get_tree().create_timer(0.6).timeout
		queue_free()
		return


	var dead_enemies := {}
	for i in range(hits):
		sprite.play("strike")
		for enemy in enemies_in_range:
			if enemy and enemy.is_inside_tree():
				if enemy in radius_hitbox.get_overlapping_bodies():
					if enemy.has_method("take_damage"):
						var is_dead = false
						if enemy.has_method("state"):
							if enemy.state == "dead" or enemy.state == "hurt":
								is_dead = true
						if not dead_enemies.has(enemy) and not is_dead:
							enemy.take_damage(damage)
							if enemy.has_method("cur_hp") and (enemy.cur_hp - damage) <= 0:
								dead_enemies[enemy] = true

		await get_tree().create_timer(interval).timeout
		
	await sprite.animation_finished


func _on_body_entered(body: Node2D):
	if !body.is_in_group("Enemy"):
		return

	if body not in enemies_in_range:
		enemies_in_range.append(body)

func _on_body_exited(body: Node2D):
	enemies_in_range.erase(body)

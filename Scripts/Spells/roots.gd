extends Area2D

@export var active_time : float = 2.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var radius_hitbox: Area2D = $Radius

var slowed_enemies : Array = []

func _ready() -> void:
	if get_parent().is_in_group("Enemy"):
		position = Vector2.ZERO
		get_parent().tree_exited.connect(queue_free)
		if get_parent().has_method("state") and get_parent().state == "dead":
			queue_free()
			return
		if get_parent().state == "dead":
			queue_free()
			return
		_on_radius_hitbox_body_entered(get_parent())

		sprite.play("start")
		await sprite.animation_finished
		await get_tree().create_timer(0.1).timeout

		if slowed_enemies.is_empty():
			queue_free()
			return

		await get_tree().create_timer(active_time).timeout
		sprite.play("end")
		await sprite.animation_finished

		for enemy in slowed_enemies:
			if enemy and enemy.is_inside_tree():
				enemy.remove_root_slow()

		queue_free()
		return

	radius_hitbox.monitoring = true
	radius_hitbox.body_entered.connect(_on_radius_hitbox_body_entered)
	radius_hitbox.area_entered.connect(_on_radius_hitbox_area_entered)

	await get_tree().physics_frame

	var overlapping_bodies = radius_hitbox.get_overlapping_bodies()
	for body in overlapping_bodies:
		_on_radius_hitbox_body_entered(body)
	for area in radius_hitbox.get_overlapping_areas():
		_on_radius_hitbox_area_entered(area)

	sprite.play("start")
	await sprite.animation_finished
	await get_tree().create_timer(0.1).timeout

	if slowed_enemies.is_empty():
		queue_free()
		return

	await get_tree().create_timer(active_time).timeout
	sprite.play("end")
	await sprite.animation_finished

	for enemy in slowed_enemies:
		if enemy and enemy.is_inside_tree():
			enemy.remove_root_slow()

	queue_free()

func _on_radius_hitbox_body_entered(body: Node2D) -> void:
	if !body.is_in_group("Enemy"):
		return

	if body.state == "dead":
		return

	if body not in slowed_enemies:
		body.apply_root_slow()
		slowed_enemies.append(body)

func _on_radius_hitbox_area_entered(area: Area2D) -> void:
	var body = area
	if !body.is_in_group("Enemy"):
		return

	if body.state == "dead":
		return

	if body not in slowed_enemies:
		body.apply_root_slow()
		slowed_enemies.append(body)

func set_upgrade_values(_active_time: float):
	active_time = _active_time

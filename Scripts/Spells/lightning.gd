extends Area2D

@export var hits : int = 3
@export var interval : float = 0.4
@export var damage : int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var radius_hitbox: Area2D = $AOE
@onready var camera = get_tree().get_first_node_in_group("Player").get_node("Camera2D")
@onready var lightning_sound1 = $Lightning1
@onready var lightning_sound2 = $Lightning2
@onready var lightning_sound3 = $Lightning3

func _ready():
	sprite.hide()
	await get_tree().physics_frame

	for i in range(hits):
		await get_tree().create_timer(0.05).timeout

		var bodies = radius_hitbox.get_overlapping_bodies()
		var unique_enemies := {}
		for body in bodies:
			if body.is_in_group("Enemy") and body.has_method("take_damage"):
				unique_enemies[body] = true

		for enemy in unique_enemies.keys():
			if is_instance_valid(enemy):
				lighting_sound()
				camera.shake(8)
				enemy.take_damage(damage)
				var fx = sprite.duplicate()
				enemy.add_child(fx)
				fx.position = Vector2(0, -10)
				fx.show()
				fx.play("strike")

		await get_tree().create_timer(interval).timeout
	await get_tree().create_timer(3).timeout
	queue_free()

func lighting_sound() -> void:
	var sound_choice = randi() % 3
	var sound_player: AudioStreamPlayer2D

	if sound_choice == 0:
		sound_player = lightning_sound1.duplicate()
	elif sound_choice == 1:
		sound_player = lightning_sound2.duplicate()
	else:
		sound_player = lightning_sound3.duplicate()

	add_child(sound_player)
	sound_player.pitch_scale = randf_range(0.9, 1.2)
	sound_player.play()

	sound_player.connect("finished", Callable(sound_player, "queue_free"))

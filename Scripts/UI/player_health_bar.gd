extends TextureProgressBar

@onready var player : CharacterBody2D = $"../../Player"
@onready var label : Label = $"../Label"

func _ready() -> void:
	player.healthChanged.connect(update)
	update()

func update():
	if player.current_health < 0:
		player.current_health = 0

	value = player.current_health * 100 / player.max_health
	label.text = str(player.current_health) + " / " + str(player.max_health)

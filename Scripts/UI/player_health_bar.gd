extends TextureProgressBar

@onready var player : CharacterBody2D = $"../../Player"
@onready var label : Label = $"../Label"
var previous_health = 0

func _ready() -> void:
	player.healthChanged.connect(update)
	previous_health = player.current_health
	update()

func update():
	var health_diff = player.current_health - previous_health
	
	if health_diff > 0:
		var grow = health_diff * 10
		size.x += grow

	previous_health = player.current_health

	value = player.current_health * 100 / player.max_health

	if player.current_health < 0:
		player.current_health = 0

	label.text = str(player.current_health) + " / " + str(player.max_health)

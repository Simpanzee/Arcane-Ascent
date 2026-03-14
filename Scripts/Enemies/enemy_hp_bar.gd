extends TextureProgressBar

@onready var enemy : CharacterBody2D = $".."

func _ready() -> void:
	enemy.healthChanged.connect(update)
	position.x = -15
	update()

func update():
	if enemy.max_hp == 0:
		return
	value = enemy.cur_hp * 100 / enemy.max_hp

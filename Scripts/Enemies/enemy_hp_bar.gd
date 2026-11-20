extends TextureProgressBar

@onready var enemy : CharacterBody2D = $".."

func _ready() -> void:
	enemy.healthChanged.connect(update)
	update()

func update():
	if enemy.max_hp == 0:
		return
	
	if enemy.cur_hp == 0:
		queue_free()
		return
		
	value = enemy.cur_hp * 100 / enemy.max_hp

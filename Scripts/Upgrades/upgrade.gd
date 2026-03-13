extends Resource
class_name Upgrade

@export var name : String
@export var tier : int
@export var description : String

func apply(player):
	match name:
		"More Health":
			player.current_health += 1
			player.max_health += 1
		"Even More Health":
			player.current_health += 3
			player.max_health += 3
		"More Damage":
			player.main_attack_damage += 1
		"More Speed":
			player.move_speed += 10
		"Even More Speed":
			player.move_speed += 30

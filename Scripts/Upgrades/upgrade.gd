extends Resource
class_name Upgrade

@export var name : String
@export var description : String
@export var icon : Texture2D 

func apply(player):
	match name:
		"Vigor+":
			player.current_health += 1
			player.max_health += 1
		"Vigor++":
			player.current_health += 3
			player.max_health += 3
		"Arcane+":
			player.main_attack_damage += 1
		"Arcane++":
			player.main_attack_damage += 3
		"Agility+":
			player.move_speed += 10
		"Agility++":
			player.move_speed += 30
		"Restore":
			player.current_health = min(player.current_health + 3, player.max_health)
		"Full Restore":
			player.current_health = player.max_health

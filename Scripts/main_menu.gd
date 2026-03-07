extends Node2D

@onready var menu_theme = $MenuTheme

func _ready() -> void:
	menu_theme.play()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://game.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()

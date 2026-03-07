extends Node2D

@onready var menu_theme = $MenuTheme
@onready var click = $Click
@onready var hover = $Hover


func _ready() -> void:
	menu_theme.play()

func _on_play_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().change_scene_to_file("res://game.tscn")
	
func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.5).timeout
	get_tree().quit()

func _on_play_mouse_entered() -> void:
	hover.play()

func _on_quit_mouse_entered() -> void:
	hover.play()

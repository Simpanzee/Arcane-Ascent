extends Node2D

@onready var click = $Click
@onready var hover = $Hover

func _on_retry_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://game.tscn")

func _on_menu_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.2).timeout
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_retry_mouse_entered() -> void:
	hover.play()

func _on_menu_mouse_entered() -> void:
	hover.play()

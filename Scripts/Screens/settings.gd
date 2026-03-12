extends Control

var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

@onready var click = $Click
@onready var hover = $Hover
@onready var save_button = $Save
@onready var music_slider = $MarginContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $MarginContainer/VBoxContainer/SFXSlider

var original_settings = {
	"music": 1.0,
	"sfx": 1.0
}
var current_settings = {
	"music": 1.0,
	"sfx": 1.0
}

func _ready():
	_apply_settings(original_settings)
	current_settings = original_settings.duplicate()
	save_button.visible = false

func _apply_settings(settings: Dictionary) -> void:
	music_slider.value = settings.get("music", 1.0)
	sfx_slider.value = settings.get("sfx", 1.0)
	AudioServer.set_bus_volume_db(music, linear_to_db(settings.get("music", 1.0)))
	AudioServer.set_bus_volume_db(sfx, linear_to_db(settings.get("sfx", 1.0)))

func _on_music_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(music, linear_to_db(value))
	current_settings["music"] = value
	_check_for_changes()

func _on_sfx_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(sfx, linear_to_db(value))
	current_settings["sfx"] = value
	_check_for_changes()

func _check_for_changes() -> void:
	save_button.visible = current_settings != original_settings

func _on_save_pressed() -> void:
	click.play()
	original_settings = current_settings.duplicate()
	save_button.visible = false
	await get_tree().create_timer(0.01).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_return_pressed() -> void:
	click.play()
	_apply_settings(original_settings)
	await get_tree().create_timer(0.01).timeout
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")

func _on_return_mouse_entered() -> void:
	hover.play()

func _on_save_mouse_entered() -> void:
	hover.play()

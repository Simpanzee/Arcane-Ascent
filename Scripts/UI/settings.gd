extends Control

var music = AudioServer.get_bus_index("Music")
var sfx = AudioServer.get_bus_index("SFX")

@onready var click = $Click
@onready var hover = $Hover
@onready var save_button = $Save
@onready var music_slider = $MarginContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $MarginContainer/VBoxContainer/SFXSlider
@onready var input_menu = $CanvasLayer/InputSettings


var original_settings = {
	"music": 1.0,
	"sfx": 1.0
}
var current_settings = {
	"music": 1.0,
	"sfx": 1.0
}

func _ready():
	var loaded_audio = ConfigFileHandler.load_audio_settings()
	input_menu.keybind_changed.connect(_on_keybind_changed)
	original_settings = {
		"music": loaded_audio.get("music_volume", 1.0),
		"sfx": loaded_audio.get("sfx_volume", 1.0)
	}
	current_settings = original_settings.duplicate()
	_apply_settings(original_settings)
	save_button.visible = false
	input_menu.visible = false

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
	if current_settings != original_settings:
		save_button.visible = true

func _on_save_pressed() -> void:
	click.play()

	original_settings = current_settings.duplicate()
	save_button.visible = false

	await get_tree().create_timer(0.01).timeout

	ConfigFileHandler.save_audio_setting("sfx_volume", sfx_slider.value)
	ConfigFileHandler.save_audio_setting("music_volume", music_slider.value)

	ConfigFileHandler.save_all_keybindings()

func _on_return_pressed() -> void:
	click.play()
	_apply_settings(original_settings)
	await get_tree().create_timer(0.01).timeout
	get_tree().change_scene_to_file("res://Scenes/UI/main_menu.tscn")

func _on_return_mouse_entered() -> void:
	hover.play()

func _on_save_mouse_entered() -> void:
	hover.play()

func _on_keybinds_pressed() -> void:
	click.play()
	input_menu.visible = true

func _on_keybinds_mouse_entered() -> void:
	hover.play()

func _on_keybind_changed():
	save_button.visible = true

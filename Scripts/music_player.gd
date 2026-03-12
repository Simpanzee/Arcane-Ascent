extends Node

@onready var menu_theme: AudioStreamPlayer = $MenuTheme

# Get the index of the Music bus
var music_bus := AudioServer.get_bus_index("Music")

func play_menu():
	if !menu_theme.playing:
		menu_theme.play()

func stop_music():
	if menu_theme.playing:
		menu_theme.stop()

# Set the volume of the Music bus in decibels
func set_volume_db(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, value)

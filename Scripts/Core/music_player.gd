extends Node

@onready var menu_theme: AudioStreamPlayer = $MenuTheme
@onready var menu_ambience: AudioStreamPlayer = $MenuAmbience
var music_bus := AudioServer.get_bus_index("Music")

func play_menu():
	if !menu_theme.playing:
		menu_theme.volume_db = 0.0
		menu_theme.play()

	if !menu_ambience.playing:
		menu_ambience.volume_db = 0.0
		menu_ambience.play()

func stop_music():
	menu_theme.stop()
	menu_ambience.stop()

func fade_out_music(duration: float = 3.0) -> Tween:
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(menu_theme, "volume_db", -40.0, duration)
	tween.tween_property(menu_ambience, "volume_db", -40.0, duration)
	tween.finished.connect(func():
		menu_theme.stop()
		menu_ambience.stop()
		menu_theme.volume_db = 0.0
		menu_ambience.volume_db = 0.0
	)

	return tween

func set_volume_db(value: float) -> void:
	AudioServer.set_bus_volume_db(music_bus, value)

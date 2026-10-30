
extends Node2D

@onready var click = $Click
@onready var hover = $Hover
@onready var demon = $Demon
@onready var fire1 = $Fire
@onready var fire2 = $Fire2
@onready var fire3 = $Fire3
@onready var bat1 = $Bat1
@onready var bat2 = $Bat2
@onready var bat3 = $Bat3
@onready var fade_rect = $ColorRect

func _ready() -> void:
	fade_rect.color = Color(0, 0, 0, 0)
	demon.play("default")
	fire1.play("default")
	fire2.play("default")
	fire3.play("default")

	bat1.play("default")
	bat2.play("default")
	bat3.play("default")

	fly_bat(bat1, 250)
	fly_bat(bat2, 300)
	fly_bat(bat3, 200)

	ConfigFileHandler.apply_keybindings()
	ConfigFileHandler.apply_audio_settings()
	MusicPlayer.play_menu()

func fly_bat(bat: AnimatedSprite2D, speed: float) -> void:
	while true:
		var screen_width = get_viewport_rect().size.x
		bat.position.x = -100
		bat.flip_h = false

		var tween = create_tween()
		tween.tween_property(bat, "position:x", screen_width + 100, screen_width / speed)
		await tween.finished

		await get_tree().create_timer(randf_range(5, 10)).timeout
		bat.position.x = screen_width + 100
		bat.flip_h = true
		tween = create_tween()
		tween.tween_property(bat, "position:x", -100, screen_width / speed)
		await tween.finished
		await get_tree().create_timer(randf_range(5, 10)).timeout

func leave_menu() -> void:
	get_tree().change_scene_to_file("res://game.tscn")

func _on_play_pressed() -> void:
	click.play()
	$ButtonManager.hide()
	$Title.hide()
	$Version.hide()
	$TextureRect.hide()
	var music_tween = MusicPlayer.fade_out_music(3.0)
	var screen_tween = create_tween()
	screen_tween.tween_property(fade_rect, "color:a", 1.0, 3.0)
	await screen_tween.finished
	await get_tree().create_timer(3).timeout
	leave_menu()

func _on_play_mouse_entered() -> void:
	hover.play()

func _on_quit_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().quit()

func _on_quit_mouse_entered() -> void:
	hover.play()

func _on_settings_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.25).timeout
	get_tree().change_scene_to_file("res://Scenes/UI/settings.tscn")

func _on_settings_mouse_entered() -> void:
	hover.play()

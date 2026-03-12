extends Node2D

@onready var click = $Click
@onready var hover = $Hover
@onready var walk = $Walk

@onready var sprite = $AnimatedSprite2D

@onready var play_button = $ButtonManager/Play
@onready var quit_button = $ButtonManager/Quit
@onready var settings_button = $ButtonManager/Settings

var running := false
var run_speed := 300
var leaving := false

func _ready() -> void:
	sprite.play("default")
	MusicPlayer.play_menu()

func _process(delta):
	if running:
		sprite.position.x -= run_speed * delta
		
		if sprite.position.x < -100 and not leaving:
			leave_menu()

func leave_menu() -> void:
	leaving = true
	running = false
	var fade_time := 2.0
	var steps := 5
	for i in steps:
		walk.volume_db = lerp(0.0, -40.0, float(i) / steps)
		await get_tree().create_timer(fade_time / steps).timeout
	
	walk.stop()
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://game.tscn")

func _on_play_pressed() -> void:
	click.play()
	MusicPlayer.stop_music()
	sprite.play("run")
	walk.play()
	running = true
	$ButtonManager.hide()
	$Title.hide()
	await get_tree().create_timer(0.6).timeout
	$Staff.hide()

func _on_play_mouse_entered() -> void:
	hover.play()

func _on_quit_pressed() -> void:
	click.play()
	get_tree().quit()

func _on_quit_mouse_entered() -> void:
	hover.play()

func _on_settings_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.01).timeout
	get_tree().change_scene_to_file("res://Scenes/UI/settings.tscn")

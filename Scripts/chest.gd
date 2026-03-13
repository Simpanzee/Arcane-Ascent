extends StaticBody2D

@onready var closed_sprite : Sprite2D = $closed
@onready var open_sprite : Sprite2D = $open
@onready var active_area : Area2D = $active_area
@onready var label : Label = $Label

var player_near : bool = false
var chest_opened : bool = false

var upgrade_pool = [
	preload("res://Scripts/Upgrades/resources/more_health.tres"),
	preload("res://Scripts/Upgrades/resources/even_more_health.tres"),
	
	preload("res://Scripts/Upgrades/resources/more_damage.tres"),
	
	preload("res://Scripts/Upgrades/resources/more_speed.tres")
]

func _ready() -> void:
	closed_sprite.visible = true
	open_sprite.visible = false
	label.visible = false

func _process(_delta: float) -> void:
	if player_near and Input.is_action_just_pressed("open") and chest_opened == false:
		open_chest()


func _on_active_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near = true
		label.visible = true


func _on_active_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near = false
		label.visible = false
		
func open_chest():
	chest_opened = true
	open_sprite.visible = true
	closed_sprite.visible = false
	
	var choices = []
	while choices.size() < 4:
		var upgrade = upgrade_pool[randi() % upgrade_pool.size()]
		choices.append(upgrade)

	get_tree().call_group("Upgrade_Menu", "open_selection", choices)

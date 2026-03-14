extends StaticBody2D

@onready var sprite = $AnimatedSprite2D
@onready var active_area: Area2D = $active_area
@onready var label: Label = $Label

var player_near: bool = false
var chest_opened: bool = false
var loot_generator: Node

var silver_upgrade_pool = [
	preload("res://Scripts/Upgrades/resources/more_health.tres"),
	preload("res://Scripts/Upgrades/resources/more_damage.tres"),
	preload("res://Scripts/Upgrades/resources/more_speed.tres")
]

var gold_upgrade_pool = [
	preload("res://Scripts/Upgrades/resources/even_more_health.tres"),
	preload("res://Scripts/Upgrades/resources/even_more_speed.tres")
]

func _ready() -> void:
	loot_generator = preload("res://Scripts/Lootbox Generator/lootbox.gd").new()
	sprite.play("default")

	update_label_key()
	label.visible = false

func update_label_key():
	var events = InputMap.action_get_events("interact")

	if events.size() > 0:
		var key = events[0].as_text().trim_suffix(" (Physical)")
		label.text = "[" + key + "] Open"
	else:
		label.text = "[?] Open"

func _process(_delta: float) -> void:
	if player_near and not chest_opened:
		label.visible = true
	else:
		label.visible = false

	if player_near and Input.is_action_just_pressed("interact") and not chest_opened:
		open_chest()

func _on_active_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near = true

func _on_active_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_near = false

func open_chest():
	chest_opened = true
	label.visible = false
	
	sprite.play("open")
	await get_tree().create_timer(1).timeout

	var lootboxes = loot_generator.generate_loot(1, 1, 0.0, 1)
	var lootbox = lootboxes[0]
	var choices = pick_upgrades(lootbox)

	get_tree().call_group("Upgrade_Menu", "open_selection", choices)

func pick_upgrades(lootbox: Dictionary) -> Array:
	var selected_upgrades : Array = []

	for tier_name in lootbox["loot"].keys():
		var count = lootbox["loot"][tier_name]
		var tier = int(tier_name.split(" ")[1])  # Converts "Tier 1" to 1
		var tier_pool

		if tier == 1:
			tier_pool = silver_upgrade_pool.duplicate()
		elif tier == 2:
			tier_pool = gold_upgrade_pool.duplicate()

		for i in range(count):
			if tier_pool.size() == 0:
				break  # No more upgrades of this tier left
			var index = randi() % tier_pool.size()
			selected_upgrades.append(tier_pool[index])
			tier_pool.remove_at(index)  # prevent duplicates

	return selected_upgrades

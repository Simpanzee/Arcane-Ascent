extends CanvasLayer

@onready var container : HBoxContainer = $HBoxContainer
var upgrade_card_scene = preload("res://Scenes/UI/upgrade_card.tscn")

func _ready() -> void:
	visible = false
	
func open_selection(upgrades):
	visible = true
	clear_children(container)
	
	for upgrade in upgrades:
		var card = upgrade_card_scene.instantiate()
		container.add_child(card)
		card.setup(upgrade)

func clear_children(node):
	for child in node.get_children():
		child.queue_free()

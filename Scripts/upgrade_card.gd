extends PanelContainer

var upgrade : Upgrade
@onready var Name_Label = $VBoxContainer/Name
@onready var Tier_Label = $VBoxContainer/Tier
@onready var Desc_Label = $VBoxContainer/Desc
@onready var button = $VBoxContainer/Button

func setup(new_upgrade : Upgrade):
	upgrade = new_upgrade
	Name_Label.text = upgrade.name
	match upgrade.tier:
		1:
			Tier_Label.text = "Tier: Silver"
		2:
			Tier_Label.text = "Tier: Gold"
	Desc_Label.text = upgrade.description

func _on_button_pressed() -> void:
	var player = get_tree().get_first_node_in_group("Player")
	player.apply_upgrade(upgrade)
	get_tree().get_first_node_in_group("Upgrade_Menu").visible = false

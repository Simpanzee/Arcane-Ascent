extends TextureRect
var upgrade : Upgrade
var zoomed_in = false
var interactable = false

@onready var Name_Label = $VBoxContainer/NameContainer/Name
@onready var Desc_Label = $VBoxContainer/DescContainer/Desc
@onready var sprite = $AnimatedSprite2D
@onready var Icon = $Icon
@onready var gold = $Gold
@onready var card = $Card
@onready var upgrade_sound = $Upgrade

const ZOOM_SCALE = 1.1
const ZOOM_SPEED = 0.15

func setup(data: Dictionary):
	upgrade = data["upgrade"]
	Name_Label.text = upgrade.name
	Desc_Label.text = upgrade.description
	Icon.texture = upgrade.icon
	gold.visible = data.has("tier") and data["tier"] == 2

func _ready():
	mouse_filter = Control.MOUSE_FILTER_STOP
	pivot_offset = size / 2
	sprite.visible = false
	enable_interaction()

func enable_interaction():
	await get_tree().create_timer(1).timeout
	interactable = true
	mouse_filter = Control.MOUSE_FILTER_STOP

func _on_mouse_entered():
	if interactable:
		sprite.visible = true
		card.play()
		sprite.play("default")
		zoomed_in = true
		tween_zoom(ZOOM_SCALE)

func _on_mouse_exited():
	if interactable:
		sprite.visible = false
		zoomed_in = false
		tween_zoom(1.0)

func _on_gui_input(event):
	if interactable:
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				player.apply_upgrade(upgrade)
				await get_tree().create_timer(0.2).timeout
				player.can_input = true
			upgrade_sound.play()
			get_tree().get_first_node_in_group("Upgrade_Menu").visible = false

func tween_zoom(target_scale: float) -> void:
	if not is_inside_tree():
		return
	var tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2(target_scale, target_scale), ZOOM_SPEED)

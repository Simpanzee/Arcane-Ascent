extends CanvasLayer

@onready var container : HBoxContainer = $CenterContainer/HBoxContainer
var upgrade_card_scene = preload("res://Scenes/UI/upgrade_card.tscn")

@onready var card1 = $Card1
@onready var card2 = $Card2
@onready var card3 = $Card3
@onready var card4 = $Card4
@onready var card5 = $Card5

const SLIDE_DISTANCE = 220
const SLIDE_TIME = 0.8
const CARD_DELAY = 0.35
const FADE_TIME = 0.10

func _ready() -> void:
	randomize()
	visible = false

func open_selection(upgrades):
	visible = true
	clear_children(container)
	
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.can_input = false
	
	for upgrade in upgrades:
		var card = upgrade_card_scene.instantiate()
		container.add_child(card)
		card.setup(upgrade)
		card.modulate.a = 0
		
	await get_tree().process_frame
	
	var index = 0
	for card in container.get_children():
		card.offset_top = SLIDE_DISTANCE
		animate_card(card, index)
		var delay = index * CARD_DELAY
		play_card_sound(delay)
		index += 1

func play_card_sound(delay):
	await get_tree().create_timer(delay).timeout
	var card_sound = randi() % 5
	if card_sound == 0:
		card1.pitch_scale = randf_range(0.9, 1.2)
		card1.play()
	elif card_sound == 1:
		card2.pitch_scale = randf_range(0.9, 1.2)
		card2.play()
	elif card_sound == 2:
		card3.pitch_scale = randf_range(0.9, 1.2)
		card3.play()
	elif card_sound == 3:
		card4.pitch_scale = randf_range(0.9, 1.2)
		card4.play()
	else:
		card5.pitch_scale = randf_range(0.9, 1.2)
		card5.play()

func animate_card(card, index):
	var delay = index * CARD_DELAY
	var tween = get_tree().create_tween()
	tween.tween_property(
		card,
		"offset_top",
		0,
		SLIDE_TIME
	)\
	.set_delay(delay)\
	.set_trans(Tween.TRANS_CUBIC)\
	.set_ease(Tween.EASE_OUT)

	tween.parallel().tween_property(
		card,
		"modulate:a",
		1.0,
		FADE_TIME
	).set_delay(delay)

func clear_children(node):
	for child in node.get_children():
		child.queue_free()

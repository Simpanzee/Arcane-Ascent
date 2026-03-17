extends Control

signal keybind_changed

@onready var input_button_scene = preload("res://Scenes/UI/input_button.tscn")
@onready var action_list = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList
@onready var click = $Click
@onready var hover = $Hover

var is_remapping = false
var action_to_remap = null
var remapping_button = null

var input_actions = {
	"move_up" : "Move Up",
	"move_left" : "Move Left",
	"move_down" : "Move Down",
	"move_right" : "Move Right",
	"primary" : "Primary Fire",
	"ability_1" : "Ability 1",
	"ability_2" : "Ability 2",
	"ability_3" : "Ability 3",
	"ultimate" : "Ultimate Ability",
	"interact" : "Interact"
}

func _ready():
	_load_keybindings_from_settings()
	_create_action_list()
	
func _load_keybindings_from_settings():
	var keybindings = ConfigFileHandler.load_keybindings()
	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()

	for action in input_actions:
		var button = input_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		action_label.text = input_actions[action]

		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""

		action_list.add_child(button)

		button.set_meta("action", action)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press Key to Bind"

func _input(event):
	if is_remapping:
		if event is InputEventKey or (event is InputEventMouseButton and event.pressed):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
				
			if _is_event_used(event):
				_restore_current_key(remapping_button, action_to_remap)
				
				is_remapping = false
				action_to_remap = null
				remapping_button = null
				return
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)

			_update_action_list(remapping_button, event)
			keybind_changed.emit()
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null

			accept_event()

func _is_event_used(event):
	for action in input_actions.keys():
		if action == action_to_remap:
			continue
		var events = InputMap.action_get_events(action)
		for e in events:
			if e.as_text() == event.as_text():
				return true
	return false

func _restore_current_key(button, action):
	var label = button.find_child("LabelInput")

	var events = InputMap.action_get_events(action)
	if events.size() > 0:
		label.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		label.text = ""

func _update_action_list(button, event):
	var label = button.find_child("LabelInput")
	label.text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed() -> void:
	click.play()
	InputMap.load_from_project_settings()
	_create_action_list()
	keybind_changed.emit()

func _on_save_button_pressed() -> void:
	click.play()
	await get_tree().create_timer(0.02).timeout
	visible = false

func _on_reset_button_mouse_entered() -> void:
	hover.play()

func _on_save_button_mouse_entered() -> void:
	hover.play()

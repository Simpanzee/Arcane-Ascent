extends Node

var config = ConfigFile.new()
const SETTINGS_FILE_PATH = "user://settings.ini"

func _ready():
	if !FileAccess.file_exists(SETTINGS_FILE_PATH):
		config.set_value("keybinding", "move_up", "W")
		config.set_value("keybinding", "move_left", "A")
		config.set_value("keybinding", "move_down", "S")
		config.set_value("keybinding", "move_right", "D")
		config.set_value("keybinding", "primary", "mouse_1")
		config.set_value("keybinding", "ability_1", "Shift")
		config.set_value("keybinding", "ability_2", "E")
		config.set_value("keybinding", "ability_3", "R")
		config.set_value("keybinding", "ultimate", "Q")
		config.set_value("keybinding", "interact", "O")
		
		config.set_value("audio", "sfx_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)


	apply_audio_settings()

func apply_audio_settings():
	var music_bus = AudioServer.get_bus_index("Music")
	var sfx_bus = AudioServer.get_bus_index("SFX")

	var music_volume = config.get_value("audio", "music_volume", 1.0)
	var sfx_volume = config.get_value("audio", "sfx_volume", 1.0)

	AudioServer.set_bus_volume_db(music_bus, linear_to_db(music_volume))
	AudioServer.set_bus_volume_db(sfx_bus, linear_to_db(sfx_volume))

func save_audio_setting(key: String, value):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings():
	var audio_settings = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings

func save_keybinding(action: StringName, event: InputEvent):
	var event_str
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)

func load_keybindings():
	var keybindings = {}
	var keys = config.get_section_keys("keybinding")

	for key in keys:
		var event_str = config.get_value("keybinding", key)
		var input_event

		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.physical_keycode = OS.find_keycode_from_string(event_str)

		if input_event != null:
			keybindings[key] = input_event

	return keybindings

func save_all_keybindings():
	var actions = [
		"move_up",
		"move_left",
		"move_down",
		"move_right",
		"primary",
		"ability_1",
		"ability_2",
		"ability_3",
		"ultimate",
		"interact"
	]

	for action in actions:
		var events = InputMap.action_get_events(action)
		if events.size() > 0:
			save_keybinding(action, events[0])

func apply_keybindings():
	var keybindings = load_keybindings()

	for action in keybindings.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybindings[action])

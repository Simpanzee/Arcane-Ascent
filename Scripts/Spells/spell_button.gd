extends TextureButton

@export var cooldown: float = 5.0
@export var action_name: StringName

@onready var bar = $TextureProgressBar
@onready var timer = $Timer
@onready var time_label = $Time
@onready var key_label = $Key
@onready var overlay = $Panel

func _ready():
	bar.max_value = cooldown
	bar.value = 0
	
	update_key_label()
	
	time_label.visible = false
	overlay.visible = false
	bar.visible = false

	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func update_key_label():
	var events = InputMap.action_get_events(action_name)

	if events.size() > 0:
		key_label.text = events[0].as_text().trim_suffix(" (Physical)")
	else:
		key_label.text = ""

func start_cooldown():
	bar.max_value = cooldown
	bar.value = cooldown
	bar.visible = true
	timer.start(cooldown)
	time_label.visible = true
	overlay.visible = true
	disabled = true

func _process(_delta):
	if timer.time_left > 0:
		bar.value = timer.time_left
		time_label.text = str(snapped(timer.time_left, 0.1))
	else:
		bar.value = 0
		bar.visible = false

func _on_timer_timeout():
	bar.value = 0
	bar.visible = false
	time_label.visible = false
	overlay.visible = false
	disabled = false

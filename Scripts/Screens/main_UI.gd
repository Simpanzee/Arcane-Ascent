extends CanvasLayer

@onready var floor_number_label = $Floor_Number

func _ready() -> void:
	game_state.floor_number_changed.connect(_on_floor_changed)

func _on_floor_changed(num: int) -> void:
	floor_number_label.text = "Floor: " + str(num)

extends CanvasLayer

@onready var floor_number_label = $Floor_Number


func _on_room_generation_floor_number_changed(num: int) -> void:
	floor_number_label.text = "Floor: " + str(num)

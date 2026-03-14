extends Button
@onready var hover = $Hover

func _on_mouse_entered() -> void:
	hover.play()

extends Room
class_name EndRoom

signal new_floor
@onready var door_shut : StaticBody2D = $DoorToNextFloor/DoorShut
@onready var door_shut_collision : CollisionShape2D = $DoorToNextFloor/DoorShut/CollisionShape2D
@onready var door_open : TileMapLayer = $DoorToNextFloor/DoorOpen

func mark_room_cleared():
	room_cleared = true
	open_all_doors()
	open_other_rooms.emit()
	door_shut.visible = false
	door_shut_collision.call_deferred("set_disabled", true)
	door_open.visible = true


func _on_next_floor_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		new_floor.emit()

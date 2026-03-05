class_name RoomEntrance
extends Node2D

@export var direction : Room.Direction = Room.Direction.NORTH

@onready var barrier : StaticBody2D = $Barrier
@onready var barrier_collider : CollisionShape2D = $Barrier/CollisionShape2D

@onready var door : Node2D = $Door
@onready var door_shut : StaticBody2D = $Door/Door_Shut
@onready var door_shut_collision : CollisionShape2D = $Door/Door_Shut/CollisionShape2D
@onready var door_open : TileMapLayer = $Door/Door_Open

func _ready() -> void:
	pass
	
func toggle_barrier(toggle : bool):
	barrier.visible = toggle
	barrier_collider.disabled = !toggle
	
	door.visible = !toggle
	
func open_door():
	if barrier.visible:
		return
	
	door_shut.visible = false
	door_shut_collision.disabled = true
	door_open.visible = true
	
func close_door ():
	if barrier.visible:
		return
	
	door_shut.visible = true
	door_shut_collision.disabled = false
	door_open.visible = false
	
func _get_neighbor_entry_direction() -> Room.Direction:
	if direction == Room.Direction.NORTH:
		return Room.Direction.SOUTH
	elif direction == Room.Direction.SOUTH:
		return Room.Direction.NORTH
	elif direction == Room.Direction.EAST:
		return Room.Direction.WEST
	else:
		return Room.Direction.EAST

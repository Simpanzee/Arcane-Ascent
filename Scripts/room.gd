class_name Room
extends StaticBody2D

enum Direction
{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

@export var doors_always_open : bool = false

@onready var entrance_north : RoomEntrance = $Entrance_North
@onready var entrance_south : RoomEntrance = $Entrance_South
@onready var entrance_east : RoomEntrance = $Entrance_East
@onready var entrance_west : RoomEntrance = $Entrance_West

func _ready() -> void:
	initial_state()

func initial_state():
	entrance_north.toggle_barrier(true)
	entrance_south.toggle_barrier(true)
	entrance_east.toggle_barrier(true)
	entrance_west.toggle_barrier(true)
	
func set_doors(data):
	if data.north:
		entrance_north.toggle_barrier(false)

	if data.south:
		entrance_south.toggle_barrier(false)

	if data.east:
		entrance_east.toggle_barrier(false)

	if data.west:
		entrance_west.toggle_barrier(false)

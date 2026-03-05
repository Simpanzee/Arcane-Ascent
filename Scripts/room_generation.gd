class_name RoomGeneration
extends Node

class RoomData:
	var exists := false
	var north := false
	var south := false
	var east := false
	var west := false

@export var map_size : int = 7
@export var rooms_to_generate : int = randi_range(4,10)
var room_count : int = 0
var map : Array[RoomData]
var rooms : Array[Room]
var room_pos_offset : float = 480

var first_room_x : int = 3
var first_room_y : int = 3
var first_room : Room
var last_room : Room

var directions = [
	Vector2.UP,
	Vector2.DOWN,
	Vector2.RIGHT,
	Vector2.LEFT
]

var room_scene : PackedScene = preload("res://Scenes/Rooms/room_template.tscn")

@export var player : CharacterBody2D

func _ready() -> void:
	_generate()
	
func _generate():
	room_count = 0
	map.resize(map_size * map_size)
	
	_check_room(first_room_x, first_room_y, Vector2.ZERO, true)
	_instantiate_rooms()
	
func _check_room(x : int, y : int, entrance_direction : Vector2, is_first_room : bool = false):
	if room_count >= rooms_to_generate:
		return false
		
	if x < 0 or x > map_size - 1 or y < 0 or y > map_size - 1:
		return false
		
	var existing_data = _get_map(x, y)
	if existing_data != null and existing_data.exists:
		return false
	
	room_count += 1

	var data := RoomData.new()
	data.exists = true
	
	if not is_first_room:
		if entrance_direction == Vector2.UP:
			data.south = true
		elif entrance_direction == Vector2.DOWN:
			data.north = true
		elif entrance_direction == Vector2.RIGHT:
			data.west = true
		elif entrance_direction == Vector2.LEFT:
			data.east = true
	
	_set_map(x, y, data)
	
	var possible_dirs = directions.duplicate()
	if not is_first_room:
		possible_dirs.erase(_get_opposite(entrance_direction))
		
	possible_dirs.shuffle()
	
	for dir in possible_dirs:
		var new_x = x + int(dir.x)
		var new_y = y + int(dir.y)
		
		if new_x < 0 or new_x > map_size - 1 or new_y < 0 or new_y > map_size - 1:
			continue
		
		var neighbor_data = _get_map(new_x, new_y)
		if neighbor_data != null and neighbor_data.exists:
			continue
			
		if _check_room(new_x, new_y, dir):
			if dir == Vector2.UP:
				data.north = true
			elif dir == Vector2.DOWN:
				data.south = true
			elif dir == Vector2.RIGHT:
				data.east = true
			elif dir == Vector2.LEFT:
				data.west = true
	
	return true
	
func _instantiate_rooms():
	for x in range(map_size):
		for y in range(map_size):
			if _get_map(x, y) == null or _get_map(x, y).exists == false:
				continue
			var room : Room = room_scene.instantiate()
			get_tree().root.add_child.call_deferred(room)
			
			var data : RoomData = _get_map(x, y)
			room.set_doors.call_deferred(data)
			
			room.global_position = Vector2(x, y) * room_pos_offset
			
			if x == first_room_x and y == first_room_y:
				first_room = room
				first_room.player_spawn(player)
			
			last_room = room

func _get_map(x : int, y : int) -> RoomData:
	return map[x + y * map_size]
	
func _set_map(x : int, y : int, value : RoomData):
	map[x + y * map_size] = value
	
func _get_opposite(dir : Vector2) -> Vector2:
	return -dir

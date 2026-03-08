class_name Room
extends StaticBody2D

enum Direction
{
	NORTH,
	SOUTH,
	EAST,
	WEST
}

signal open_other_rooms
signal close_other_rooms

@onready var entrance_north : RoomEntrance = $Entrance_North
@onready var entrance_south : RoomEntrance = $Entrance_South
@onready var entrance_east : RoomEntrance = $Entrance_East
@onready var entrance_west : RoomEntrance = $Entrance_West

@onready var room_area : Area2D = $RoomArea
@onready var spawn_zone : Area2D = $SpawnZone

var slime_scene : PackedScene = preload("res://Scenes/Enemies/slime.tscn")
var orc_scene : PackedScene = preload("res://Scenes/Enemies/orc.tscn")
var skeleton_archer_scene : PackedScene = preload("res://Scenes/Enemies/skeleton_archer.tscn")

var enemies_count : int = randi_range(6, 10)
var room_cleared : bool = false
var is_first_room : bool = false

func _ready() -> void:
	initial_state()
	if is_first_room:
		enemies_count = 0
		mark_room_cleared.call_deferred()
		return
	spawn_enemies()

func initial_state():
	entrance_north.toggle_barrier(true)
	entrance_south.toggle_barrier(true)
	entrance_east.toggle_barrier(true)
	entrance_west.toggle_barrier(true)
	
func set_doors(data):
	if data.north:
		entrance_north.toggle_barrier(false)
		# entrance_north.open_door()

	if data.south:
		entrance_south.toggle_barrier(false)
		# entrance_south.open_door()

	if data.east:
		entrance_east.toggle_barrier(false)
		# entrance_east.open_door()

	if data.west:
		entrance_west.toggle_barrier(false)
		# entrance_west.open_door()
		

func player_spawn(player : CharacterBody2D):
	player.global_position = global_position
	
func player_enter(_player : CharacterBody2D):
	pass
	
func spawn_enemies():
	var shapes := []
	for child in spawn_zone.get_children():
		if child is CollisionShape2D and child.shape is RectangleShape2D:
			shapes.append(child)
			
	for i in range(enemies_count):
		var enemy_scene : PackedScene
		var random_num = randf()
		if random_num < 0.33:
			enemy_scene = slime_scene
		elif random_num < 0.67:
			enemy_scene = skeleton_archer_scene
		else:
			enemy_scene = orc_scene

		var enemy = enemy_scene.instantiate()
		add_child(enemy)
		
		var shape_node : CollisionShape2D = shapes[randi() % shapes.size()]
		var rect : RectangleShape2D = shape_node.shape
		
		var offset = Vector2(
			randf_range(-rect.extents.x, rect.extents.x),
			randf_range(-rect.extents.y, rect.extents.y)
		)
		
		var spawn_pos = shape_node.global_position + offset
		enemy.global_position = spawn_pos
		
		enemy.died.connect(_on_enemy_died)
	

func _on_enemy_died() -> void:
	enemies_count -= 1
	if enemies_count <= 0:
		mark_room_cleared()
		
func open_all_doors():
	entrance_north.open_door()
	entrance_south.open_door()
	entrance_east.open_door()
	entrance_west.open_door()
	
func close_all_doors():
	entrance_north.close_door()
	entrance_south.close_door()
	entrance_east.close_door()
	entrance_west.close_door()
	
func mark_room_cleared():
	room_cleared = true
	open_all_doors()
	open_other_rooms.emit()

func _on_room_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		if room_cleared == false:
			close_all_doors.call_deferred()
			close_other_rooms.emit()
			for enemy in get_children():
				if enemy.is_in_group("Enemy"):
					enemy.is_active = true

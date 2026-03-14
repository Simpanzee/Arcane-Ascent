extends Node

var floor_number : int = 1
signal floor_number_changed(num : int)

func next_floor():
	floor_number += 1
	floor_number_changed.emit(floor_number)
	
func reset():
	floor_number = 1

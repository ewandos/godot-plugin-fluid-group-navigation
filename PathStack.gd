extends Node2D
class_name PathStack

var path_stack := []

func is_empty() -> bool:
	return path_stack.size() == 0

func set_path(path: PackedVector2Array):
	path_stack.clear()
	path_stack.push_front(path)

func push_path(path: PackedVector2Array):
	path_stack.push_front(path)
	
func get_next_waypoint(current_position: Vector2) -> Vector2:
	path_stack = path_stack.filter(func(path): return path.size() != 0)
	if (path_stack.size() == 0): return current_position
	var current_path: PackedVector2Array = path_stack[0]
	var next_location = current_path[0]
	current_path.remove_at(0)
	return next_location

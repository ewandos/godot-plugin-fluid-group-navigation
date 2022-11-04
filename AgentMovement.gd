extends Node2D
class_name AgentMovement

signal path_pushed
var path := []

func set_path(new_path: PackedVector2Array) -> void:
	path = new_path
	path_pushed.emit(get_instance_id(), new_path)
	
func calc_velocity(current_position: Vector2) -> Vector2:
	if (path.size() == 0):
		return Vector2.ZERO
		
	var next_waypoint = path[0]
	var distance = current_position.distance_to(next_waypoint)
	
	if (distance <= 10):
		path.remove_at(0)
	
	var velocity = (next_waypoint - current_position).normalized()
	
	var new_position = current_position + velocity

	return velocity

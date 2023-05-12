class_name MovementInfo
extends Object

var is_completed := false
var path: PackedVector2Array = []
var velocities: PackedVector2Array = []
var positions: PackedVector2Array = []
var collision_count := 0
var time_in_ms := 0.0

func get_path_length() -> float:
	var summed_distance := 0.0
	for i in path.size() - 1:
		summed_distance += path[i].distance_to(path[i + 1])
	return summed_distance

func get_traveled_path_length() -> float:
	var summed_distance := 0.0
	for i in positions.size() - 1:
		summed_distance += positions[i].distance_to(positions[i + 1])
	return summed_distance

func get_velocity_mean() -> float:
	var mean_velocity := 0.0
	for velocity in velocities:
		mean_velocity += velocity.length();
	mean_velocity /= velocities.size()
	return mean_velocity

func get_velocity_standard_deviation() -> float:
	var mean_velocity := get_velocity_mean()

	var summed_squared_differences := 0.0
	for velocity in velocities:
		summed_squared_differences += pow(velocity.length() - mean_velocity, 2)

	return sqrt((1.0 / velocities.size()) * summed_squared_differences)

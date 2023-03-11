@tool
extends Node2D
class_name FluidAgentNavigation

@onready var area: Area2D = $Area2D
@export_flags_2d_navigation var navigation_group: int
@export var show_debug: bool = false
@export var agent_attributes: AgentAttributes
@export var path_stopping_distance := 10

signal path_pushed
var path := []
var path_offset := Vector2.ZERO
var acceleration := Vector2.ZERO
var velocity := Vector2.ZERO
var target_reached_distance := 5.0
var heading := Vector2.RIGHT
var heading_smoother := HeadingSmoother.new(10)
var is_sleeping := true
var neighbors: Array[Node2D] = []
var force_nodes: Array[BaseForce] = []
var cummulative_steering_force := Vector2.ZERO


func _ready() -> void:
	heading = heading.rotated(global_rotation)
	force_nodes.assign(find_children("*", "BaseForce", true))


func set_destination(target: Vector2, with_offset: Vector2 = Vector2.ZERO) -> void:
	path = calculate_path(global_position, target)
	path_offset = with_offset
	path_pushed.emit(get_instance_id(), path)


func set_path(new_path: PackedVector2Array) -> void:
	path = new_path
	path_pushed.emit(get_instance_id(), new_path)


func calc_velocity() -> Vector2:
	if path.size() == 0:
		return Vector2.ZERO

	steer()
	queue_redraw()
	return velocity


func steer() -> void:
	var steering_force = accumulate_steering_forces()
	steering_force /= agent_attributes.mass
	acceleration += steering_force

	# update velocity
	velocity += acceleration

	# limit speed
	velocity.limit_length(agent_attributes.max_speed)

	# reset acceleration to 0 each cycle
	acceleration *= 0

	velocity = apply_turning_radius(velocity)

	# smooth the heading
	heading = heading_smoother.update(velocity.normalized())


func compute_force_to_steer_to_velocity(desired_velocity: Vector2) -> Vector2:
	var steering_force := desired_velocity - velocity
	var normalized_length := steering_force.length() / desired_velocity.length()
	normalized_length = clampf(normalized_length, 0.0, 1.0)

	steering_force = steering_force.normalized()
	steering_force *= agent_attributes.max_force * normalized_length

	return steering_force


func compute_seek_force(in_target: Vector2, in_b_slowdown: bool) -> Vector2:
	const slowdown_distance := 100.0
	var desired := in_target - global_position
	var distance_to_target = desired.length()

	if distance_to_target <= 0: return Vector2.ZERO

	desired = desired.normalized()
	if in_b_slowdown:
		var velocity_scalar := distance_to_target / slowdown_distance as float
		velocity_scalar = clampf(velocity_scalar, 0.0, 1.0)
		desired *= agent_attributes.max_speed * velocity_scalar
	else:
		desired *= agent_attributes.max_speed

	return compute_force_to_steer_to_velocity(desired)


func accumulate_steering_forces() -> Vector2:
	cummulative_steering_force = Vector2.ZERO
	neighbors = area.get_overlapping_bodies()

	for force in force_nodes:
		cummulative_steering_force += force.calculate_force(self) * force.weight
		if cummulative_steering_force.length() > agent_attributes.max_force:
			break

	return cummulative_steering_force


func calculate_path(start_position: Vector2, target_position: Vector2) -> PackedVector2Array:
	var parameter := NavigationPathQueryParameters2D.new()
	parameter.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL
	parameter.start_position = start_position
	parameter.target_position = target_position
	parameter.map = NavigationServer2D.get_maps()[0]
	var query_result := NavigationPathQueryResult2D.new()
	NavigationServer2D.query_path(parameter, query_result)
	var result := query_result.get_path()
	result.remove_at(0)
	return result


func apply_turning_radius(steering_force: Vector2) -> Vector2:
	var force_angle = abs(steering_force.angle_to(heading))
	var angle_in_degree = rad_to_deg(force_angle)
	var max_angle_rad = deg_to_rad(agent_attributes.turning_radius)

	if force_angle > max_angle_rad:
		var is_right := heading.cross(cummulative_steering_force) > 0
		var angle_correction = force_angle - max_angle_rad

		if is_right:
			angle_correction *= -1

		return steering_force.rotated(angle_correction)
	return steering_force


func _draw():
	if not show_debug: return
	for force_node in force_nodes:
		draw_line(Vector2.ZERO, force_node.steering_force.rotated(-global_rotation) * 20, force_node.debug_color, 2)

extends Node2D
class_name NavigationAgent

@onready var area: Area2D = $Area2D
@export_flags_2d_navigation var navigation_group: int
@export var force_distance_scalar: Curve
@export var show_debug: bool = false
@export var agent_attributes: AgentAttributes

signal path_pushed
var path := []

var acceleration := Vector2.ZERO
var velocity := Vector2.ZERO
var target_reached_distance := 5.0
var heading := Vector2.RIGHT
var heading_smoother := HeadingSmoother.new(10)

var steering_force := Vector2.ZERO
var path_follow_force := Vector2.ZERO
var obstacle_avoidance_force := Vector2.ZERO
var separation_steering_force := Vector2.ZERO
var alignment_steering_force := Vector2.ZERO
var cohesion_steering_force := Vector2.ZERO


func _ready() -> void:
	heading = heading.rotated(global_rotation)

func set_target(target: Vector2) -> void:
	path = Pathfinder.calculate_path(global_position, target)


func set_path(new_path: PackedVector2Array) -> void:
	path = new_path
	path_pushed.emit(get_instance_id(), new_path)


func calc_velocity() -> Vector2:
	if (path.size() == 0):
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

	# smooth the heading
	heading = heading_smoother.update(velocity.normalized())

func compute_path_follow_force() -> Vector2:
	var next_waypoint = path[0]
	var distance = global_position.distance_to(next_waypoint)

	if (distance <= 10):
		path.remove_at(0)

	if path.size() == 0:
		return Vector2.ZERO

	var steering_force := Vector2.ZERO
	steering_force = global_position.direction_to(path[0])
	steering_force *= agent_attributes.max_speed

	return compute_force_to_steer_to_velocity(steering_force)


func calculate_obstacle_avoidance_steering_force(neighbors: Array[Node2D]) -> Vector2:
	var steering_force := Vector2.ZERO
	var counter_clockwise_perp = heading.orthogonal().normalized()
	var rotation_angle_radians = heading.angle()

	for neighbor in neighbors:
		if neighbor.movement == self: continue
		var is_within_range := global_position.distance_to(neighbor.global_position) <= agent_attributes.neighbor_radius

		if not is_within_range: continue

		var direction_to_neighbor := global_position.direction_to(neighbor.global_position)

		var is_in_front := counter_clockwise_perp.cross(direction_to_neighbor) > 0
		var is_right := heading.cross(direction_to_neighbor) > 0

		if not is_in_front: continue

		var neighbor_collision_radius: float = neighbor.movement.agent_attributes.collision_radius

		var to_neighbor = neighbor.global_position - global_position
		var projected_sidestep = to_neighbor.project(heading)
		var sidestep_direction = (to_neighbor - projected_sidestep) * -1
		var sidestep_magnitude := (agent_attributes.collision_radius + neighbor_collision_radius) - sidestep_direction.length()

		var neighbor_neighbor_radius: float = neighbor.movement.agent_attributes.neighbor_radius
		var approaching_progress = 1- (global_position.distance_to(neighbor.global_position) / neighbor_neighbor_radius)
		var sidestep_force = sidestep_direction.normalized()
		sidestep_force *= agent_attributes.max_force
		steering_force += sidestep_force
		steering_force.limit_length(agent_attributes.max_force)
		var distance_scalar = force_distance_scalar.sample(approaching_progress)
		steering_force *= distance_scalar

	return steering_force


func compute_separation_force(neighbors: Array[Node2D]) -> Vector2:
	var steer := Vector2.ZERO
	var number_of_neighbors = 0

	for neighbor in neighbors:
		if neighbor.movement == self: continue
		var distance_to_neighbor := global_position.distance_to(neighbor.global_position)

		if distance_to_neighbor >= agent_attributes.neighbor_radius: continue

		var steering_force := neighbor.global_position.direction_to(global_position)

		var neighbor_radius: float = neighbor.movement.agent_attributes.collision_radius

		if distance_to_neighbor < (agent_attributes.collision_radius + neighbor_radius):
			steering_force *= agent_attributes.max_force
			return steering_force
		else:
			var distance := (distance_to_neighbor / neighbor_radius)
			distance = clamp(distance, 0.0, 1.0)
			steering_force *= agent_attributes.max_force * distance

		steer += steering_force
		number_of_neighbors += 1


	if number_of_neighbors > 0:
		steer /= number_of_neighbors

	return steer


func compute_alignment_force(neighbors: Array[Node2D]) -> Vector2:
	var steering_force := Vector2.ZERO
	var number_of_neighbors := 0

	for neighbor in neighbors:
		if neighbor.movement == self: continue
		var is_in_same_navigation_group: bool = neighbor.movement.navigation_group & navigation_group != 0
		if not is_in_same_navigation_group: continue
		var distance_to_neighbor = global_position.distance_to(neighbor.global_position)
		if distance_to_neighbor >= agent_attributes.neighbor_radius: continue
		var neighbor_agent: NavigationAgent = neighbor.get_node("AgentMovement")
		steering_force += neighbor_agent.heading
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		steering_force /= number_of_neighbors
		steering_force = compute_force_to_steer_to_velocity(steering_force)

	return Vector2.ZERO


func compute_cohesion_force(neighbors: Array[Node2D]) -> Vector2:
	var centroid := Vector2.ZERO
	var number_of_neighbors := 0

	for neighbor in neighbors:
		if neighbor.movement == self: continue
		var is_in_same_navigation_group: bool = neighbor.movement.navigation_group & navigation_group != 0
		if not is_in_same_navigation_group: continue
		var distance_to_neighbor = global_position.distance_to(neighbor.global_position)
		if (distance_to_neighbor >= agent_attributes.neighbor_radius): continue
		centroid += neighbor.global_position
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		centroid /= number_of_neighbors
		return compute_seek_force(centroid, false)

	return centroid


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
		var velocity_scalar := distance_to_target / slowdown_distance
		velocity_scalar = clampf(velocity_scalar, 0.0, 1.0)
		desired *= agent_attributes.max_speed * velocity_scalar
	else:
		desired *= agent_attributes.max_speed

	return compute_force_to_steer_to_velocity(desired)


func accumulate_force(in_force_to_add: Vector2, in_total_forces: Vector2):
	var magnitude_to_add := in_force_to_add.length()
	var magnitude_remaining := agent_attributes.max_force - in_total_forces.length()
	var is_force_left := magnitude_to_add < agent_attributes.max_force

	if is_force_left:
		in_force_to_add /= magnitude_to_add
		in_force_to_add *= magnitude_remaining

	in_total_forces += in_force_to_add

	return in_total_forces


func accumulate_steering_forces() -> Vector2:
	steering_force = Vector2.ZERO
	var neighbors := area.get_overlapping_bodies()

	path_follow_force = compute_path_follow_force()
	path_follow_force *= 1.3
	steering_force += path_follow_force
	if steering_force.length() > agent_attributes.max_force: return steering_force

	obstacle_avoidance_force = calculate_obstacle_avoidance_steering_force(neighbors)
	obstacle_avoidance_force *= 0.5
	steering_force += obstacle_avoidance_force
	if steering_force.length() > agent_attributes.max_force: return steering_force

	separation_steering_force = compute_separation_force(neighbors)
	separation_steering_force *= 0.2
	steering_force += separation_steering_force
	if steering_force.length() > agent_attributes.max_force: return steering_force

	alignment_steering_force = compute_alignment_force(neighbors)
	alignment_steering_force *= 1.0
	steering_force += separation_steering_force
	if steering_force.length() > agent_attributes.max_force: return steering_force

	cohesion_steering_force = compute_cohesion_force(neighbors)
	cohesion_steering_force *= 0.3
	steering_force += cohesion_steering_force

	return steering_force


func _draw():
	if not show_debug: return
	# draw_circle(Vector2.ZERO, agent_attributes.collision_radius, Color.DIM_GRAY)
	draw_line(Vector2.ZERO, velocity.rotated(-global_rotation) * 20, Color.GREEN, 2)
	draw_line(Vector2.ZERO, path_follow_force.rotated(-global_rotation) * 100, Color.RED, 2)
	draw_line(Vector2.ZERO, obstacle_avoidance_force.rotated(-global_rotation) * 100, Color.BLUE, 2)
	draw_line(Vector2.ZERO, separation_steering_force.rotated(-global_rotation) * 100, Color.YELLOW, 2)
	draw_line(Vector2.ZERO, alignment_steering_force.rotated(-global_rotation) * 100, Color.MAGENTA, 2)
	draw_line(Vector2.ZERO, cohesion_steering_force.rotated(-global_rotation) * 100, Color.BLACK, 2)

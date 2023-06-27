@tool
extends Agent
class_name FluidAgentNavigation

@export var show_debug: bool = false
@export var agent_attributes: AgentAttributes

@onready var collision_area := $CollisionArea as Area2D

var path_offset := Vector2.ZERO

# Cached values
var is_moving := false
var acceleration := Vector2.ZERO
var cummulative_steering_force := Vector2.ZERO
var neighbors: Array[Node2D] = []
var force_nodes: Array[BaseForce] = []
var heading_smoother := HeadingSmoother.new(10)
var neighbor_area: Area2D


func _ready() -> void:
	heading = heading.rotated(global_rotation)
	force_nodes.assign(find_children("*", "BaseForce", true))

	collision_area.body_entered.connect(_on_body_entered)

	if find_child("NeighborArea") != null: return

	var circle_shape_2d_res := CircleShape2D.new()
	circle_shape_2d_res.radius = agent_attributes.neighbor_radius

	var collision_shape_2d_node := CollisionShape2D.new()
	collision_shape_2d_node.shape = circle_shape_2d_res

	var area_2d_node := Area2D.new()
	area_2d_node.name = "NeighborArea"
	area_2d_node.add_child(collision_shape_2d_node)

	add_child(area_2d_node)
	neighbor_area = area_2d_node

func _on_body_entered(body: Node2D) -> void:
	if not body is Unit or body == get_parent(): return
	collided.emit(get_instance_id())

func set_destination(target: Vector2, append: bool = false) -> void:
	if append && path.size() > 0:
		path.append_array(_calculate_path(path[path.size() - 1], target))
	else:
		path = _calculate_path(global_position, target)

	path_pushed.emit(get_instance_id(), path, global_position)


func calc_velocity() -> Vector2:
	if not is_inside_tree(): await ready

	if path.size() == 0:
		if is_moving:
			is_moving = false
			path_resolved.emit(get_instance_id())
		return Vector2.ZERO

	_steer()
	queue_redraw()
	is_moving = true
	calculated_velocity.emit(get_instance_id(), velocity)
	moved.emit(get_instance_id(), global_position)
	return velocity


func _steer() -> void:
	var steering_force = _accumulate_steering_forces()
	steering_force /= agent_attributes.mass
	acceleration += steering_force
	velocity += acceleration
	velocity.limit_length(agent_attributes.max_speed)
	acceleration *= 0
	velocity = _apply_turning_radius(velocity)
	heading = heading_smoother.update(velocity.normalized())


## Computes a steering force to achieve the desired velocity
func compute_force_to_steer_to_velocity(desired_velocity: Vector2) -> Vector2:
	var steering_force := desired_velocity - velocity
	return steering_force * agent_attributes.max_force


## Computes a steering force to achieve movement to the desired target position
func compute_seek_force(desired_position: Vector2) -> Vector2:
	const slowdown_distance := 100.0
	var desired_velocity := desired_position - global_position
	var distance_to_target = desired_velocity.length()

	if distance_to_target <= 0: return Vector2.ZERO

	desired_velocity = desired_velocity.normalized()

	# apply an slacar that decreases the velocity
	# the more closer the agent gets to the target
	var velocity_scalar := distance_to_target / slowdown_distance as float
	velocity_scalar = clampf(velocity_scalar, 0.0, 1.0)
	desired_velocity *= agent_attributes.max_speed * velocity_scalar

	return compute_force_to_steer_to_velocity(desired_velocity)


func _accumulate_steering_forces() -> Vector2:
	cummulative_steering_force = Vector2.ZERO
	neighbors = neighbor_area.get_overlapping_bodies()

	for force in force_nodes:
		cummulative_steering_force += force.get_force(self)
		if cummulative_steering_force.length() > agent_attributes.max_force:
			break

	return cummulative_steering_force


func _calculate_path(start_position: Vector2, target_position: Vector2) -> PackedVector2Array:
	var result := get_tree().get_first_node_in_group('grid').calculate_path(start_position, target_position) as PackedVector2Array
	if result.size() == 0: return result
	return result


func _apply_turning_radius(steering_force: Vector2) -> Vector2:
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
		draw_line(Vector2.ZERO, force_node.force.rotated(-global_rotation) * 100, force_node.debug_color, 2)

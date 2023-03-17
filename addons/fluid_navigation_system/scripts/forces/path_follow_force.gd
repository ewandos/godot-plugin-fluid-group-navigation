@tool
class_name PathFollowForce
extends BaseForce

## Follow the provided path
func _calculate_force(agent: FluidAgentNavigation) -> Vector2:
	var steering_force = Vector2.ZERO

	if agent.path.size() == 0: return Vector2.ZERO

	var oriented_path_offset := agent.path_offset
	if agent.path.size() > 1:
		var path_orientation: Vector2 = agent.path[0].direction_to(agent.path[1])
		var orientation_angle := path_orientation.angle()
		oriented_path_offset = agent.path_offset.rotated(orientation_angle)

	var distance = agent.global_position.distance_to(agent.path[0] + oriented_path_offset)

	if (distance <= agent.agent_attributes.path_stopping_distance):
		agent.path.remove_at(0)

	if agent.path.size() == 0: return Vector2.ZERO

	steering_force = agent.global_position.direction_to(agent.path[0] + oriented_path_offset)
	steering_force *= agent.agent_attributes.max_speed

	return agent.compute_force_to_steer_to_velocity(steering_force)

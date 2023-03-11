@tool
class_name PathFollowForce
extends BaseForce

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	steering_force = Vector2.ZERO
	var distance = agent.global_position.distance_to(agent.path[0])

	if (distance <= agent.path_stopping_distance):
		agent.path.remove_at(0)

	if agent.path.size() == 0:
		return Vector2.ZERO

	steering_force = agent.global_position.direction_to(agent.path[0])
	steering_force *= agent.agent_attributes.max_speed
	return agent.compute_force_to_steer_to_velocity(steering_force)

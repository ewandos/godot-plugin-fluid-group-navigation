@tool
class_name AgentAvoidanceForce
extends BaseForce

@export var agent_avoidance_distance_scalar: Curve

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	steering_force = Vector2.ZERO
	var counter_clockwise_perp = agent.heading.orthogonal().normalized()

	for neighbor in agent.neighbors:
		if neighbor.movement == self: continue
		var is_within_range := agent.global_position.distance_to(neighbor.global_position) <= agent.agent_attributes.neighbor_radius

		if not is_within_range: continue

		var direction_to_neighbor := global_position.direction_to(neighbor.global_position)

		var is_in_front := counter_clockwise_perp.cross(direction_to_neighbor) > 0

		if not is_in_front: continue

		var to_neighbor = neighbor.global_position - global_position
		var projected_sidestep = to_neighbor.project(agent.heading)
		var sidestep_direction = (to_neighbor - projected_sidestep) * -1

		var neighbor_neighbor_radius: float = neighbor.movement.agent_attributes.neighbor_radius
		var approaching_progress = 1- (global_position.distance_to(neighbor.global_position) / neighbor_neighbor_radius)
		var sidestep_force = sidestep_direction.normalized()
		sidestep_force *= agent.agent_attributes.max_force
		steering_force += sidestep_force

		var priority_scalar: float = neighbor.movement.agent_attributes.priority / agent.agent_attributes.priority
		priority_scalar = floorf(priority_scalar)
		steering_force *= priority_scalar
		steering_force.limit_length(agent.agent_attributes.max_force)
		var distance_scalar = agent_avoidance_distance_scalar.sample(approaching_progress)

		steering_force *= distance_scalar

	return steering_force

@tool
class_name SeparationSteeringForce
extends BaseForce

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	steering_force = Vector2.ZERO
	var number_of_neighbors = 0

	for neighbor in agent.neighbors:
		if neighbor.movement == self: continue
		var distance_to_neighbor := global_position.distance_to(neighbor.global_position)

		if distance_to_neighbor >= agent.agent_attributes.neighbor_radius: continue

		var neighbor_force := neighbor.global_position.direction_to(agent.global_position)

		var neighbor_radius: float = neighbor.movement.agent_attributes.collision_radius

		if distance_to_neighbor < (agent.agent_attributes.collision_radius + neighbor_radius):
			neighbor_force *= agent.agent_attributes.max_force
			return neighbor_force
		else:
			var distance := (distance_to_neighbor / neighbor_radius)
			distance = clamp(distance, 0.0, 1.0)
			neighbor_force *= agent.agent_attributes.max_force * distance

		var priority_scalar: float = neighbor.movement.agent_attributes.priority / agent.agent_attributes.priority
		priority_scalar = floorf(priority_scalar)
		neighbor_force *= priority_scalar

		steering_force += neighbor_force
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		steering_force /= number_of_neighbors

	return steering_force

@tool
class_name CohesionForce
extends BaseForce

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	steering_force = Vector2.ZERO
	var number_of_neighbors := 0

	for neighbor in agent.neighbors:
		if neighbor.movement == agent: continue

		var is_in_same_navigation_group: bool = neighbor.movement.navigation_group & agent.navigation_group != 0
		if not is_in_same_navigation_group: continue

		var distance_to_neighbor = agent.global_position.distance_to(neighbor.global_position)
		if (distance_to_neighbor >= agent.agent_attributes.neighbor_radius): continue

		steering_force += neighbor.global_position
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		steering_force /= number_of_neighbors
		steering_force = agent.compute_seek_force(steering_force, false)

	return steering_force

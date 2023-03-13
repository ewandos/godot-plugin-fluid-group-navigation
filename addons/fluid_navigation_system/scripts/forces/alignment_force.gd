@tool
class_name AlignmentForce
extends BaseForce

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	steering_force = Vector2.ZERO
	var number_of_neighbors := 0

	for neighbor in agent.neighbors:
		if neighbor.movement == agent: continue
		var is_in_same_navigation_group: bool = neighbor.movement.navigation_group & agent.navigation_group != 0
		if not is_in_same_navigation_group: continue
		var distance_to_neighbor = global_position.distance_to(neighbor.global_position)
		if distance_to_neighbor >= agent.agent_attributes.neighbor_radius: continue
		var neighbor_agent: FluidAgentNavigation = neighbor.get_node("AgentMovement")
		steering_force += neighbor_agent.heading
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		steering_force /= number_of_neighbors
		steering_force = agent.compute_force_to_steer_to_velocity(steering_force)

	return steering_force

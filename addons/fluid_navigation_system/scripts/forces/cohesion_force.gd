@tool
class_name CohesionForce
extends BaseForce

## Move towards the average position of neighboring agents
func _calculate_force(agent: FluidAgentNavigation) -> Vector2:
	var steering_force := Vector2.ZERO
	var average_neighbor_position := Vector2.ZERO
	var number_of_neighbors := 0

	for neighbor in agent.neighbors:
		if neighbor.is_in_group("agent") and neighbor.movement == agent: continue
		average_neighbor_position += neighbor.global_position
		number_of_neighbors += 1

	if number_of_neighbors > 0:
		average_neighbor_position /= number_of_neighbors
		steering_force = agent.compute_seek_force(average_neighbor_position)

	return steering_force

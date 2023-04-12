@tool
class_name SeparationSteeringForce
extends BaseForce

## Separate two agents from another and keep them from overlapping
func _calculate_force(agent: FluidAgentNavigation) -> Vector2:
	var steering_force = Vector2.ZERO
	var number_of_neighbors = 0

	for neighbor in agent.neighbors:

		# ignore the own agent
		if neighbor.is_in_group("agent") and neighbor.movement == agent: continue

		var distance_to_neighbor := agent.global_position.distance_to(neighbor.global_position)

		if distance_to_neighbor >= agent.agent_attributes.neighbor_radius: continue

		var neighbor_force := neighbor.global_position.direction_to(agent.global_position)
		var neighbor_radius: float = neighbor.movement.agent_attributes.collision_radius

		# if two agents overlap each other, use max force
		if distance_to_neighbor < (agent.agent_attributes.collision_radius + neighbor_radius):
			neighbor_force *= agent.agent_attributes.max_force
			return neighbor_force

		# else interpolate based on the distance between the two agents
		else:
			var distance := (distance_to_neighbor / neighbor_radius)
			distance = clamp(distance, 0.0, 1.0)
			neighbor_force *= agent.agent_attributes.max_force * distance

		# modify the force based on the priority ranking between the two agents
		var priority_scalar: float = neighbor.movement.agent_attributes.priority / agent.agent_attributes.priority
		priority_scalar = floorf(priority_scalar)
		neighbor_force *= priority_scalar

		# add the force to the steering force
		steering_force += neighbor_force
		number_of_neighbors += 1

	# calculate the average steering force
	if number_of_neighbors > 0:
		steering_force /= number_of_neighbors

	return steering_force

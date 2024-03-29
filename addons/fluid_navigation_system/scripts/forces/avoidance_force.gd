@tool
class_name AvoidanceForce
extends BaseForce

## Maps an value between [0, 1] to the apporaching progress between [0, 1] of two agents.
@export var distance_scalar_curve: Curve

## Avoid other agent's desired velocity
func _calculate_force(agent: FluidAgentNavigation) -> Vector2:
	var steering_force = Vector2.ZERO
	var counter_clockwise_perp = agent.heading.orthogonal().normalized()

	for neighbor in agent.neighbors:
		if neighbor.is_in_group("agent") and neighbor.movement == agent: continue
		if not neighbor.is_in_group("unit") and not neighbor.is_in_group('agent'): continue

		var direction_to_neighbor := agent.global_position.direction_to(neighbor.global_position)
		var is_in_front := counter_clockwise_perp.cross(direction_to_neighbor) > 0
		if not is_in_front: continue

		var to_neighbor = neighbor.global_position - agent.global_position
		var projected_sidestep = to_neighbor.project(agent.heading)
		var sidestep_direction = (to_neighbor - projected_sidestep) * -1

		var neighbor_radius_of_neighbor: float = neighbor.movement.agent_attributes.neighbor_radius
		var collision_radius_of_neighbor: float = neighbor.movement.agent_attributes.collision_radius
		var approaching_progress = 1 - ((agent.global_position.distance_to(neighbor.global_position) - collision_radius_of_neighbor) / neighbor_radius_of_neighbor)
		var sidestep_force = sidestep_direction.normalized()
		sidestep_force *= agent.agent_attributes.max_force

		var priority_scalar: float = neighbor.movement.agent_attributes.priority / agent.agent_attributes.priority
		priority_scalar = floorf(priority_scalar)
		sidestep_force *= priority_scalar
		sidestep_force.limit_length(agent.agent_attributes.max_force)
		var distance_scalar = distance_scalar_curve.sample(approaching_progress)
		sidestep_force *= distance_scalar

		steering_force += sidestep_force

	return steering_force

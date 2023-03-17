extends Resource
class_name AgentAttributes

## Mass of the agent. Affects the inertia and acceleration.
@export_range(1, 10, 0.5, "or_greater") var mass := 1.0

## Radius in pixels which the agent tries to maintain.
@export_range(1, 500, 1, "suffix:px", "or_greater") var collision_radius := 30.0

## Limit of degree that the agent can turn in one frame.
@export_range(1, 90, 1) var turning_radius := 90

## Maximum on force that can be applied to the agent before other forces are ignored.
@export_range(0, 10, 0.25, "or_greater") var max_force := 0.5

## Maximum pixels that the agent can move in one frame.
@export_range(0, 10, 1, "suffix:px", "or_greater") var max_speed := 1

## Radius in pixel that other agents are detected.
@export_range(1, 300, 1, "suffix:px", "or_greater") var neighbor_radius := 100.0

## Priority of an agent. Higher value means higher priority
@export_range(1, 10, 1, "or_greater") var priority := 1

## Distance between waypoints and the agent that needs to be met
## for considering the waypoint to be reached
@export_range(1, 100, 1, "suffix:px", "or_greater") var path_stopping_distance := 10

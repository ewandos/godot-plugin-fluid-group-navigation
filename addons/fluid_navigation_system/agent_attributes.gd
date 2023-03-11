extends Resource
class_name AgentAttributes

## Mass of the agent. Affects the inertia and acceleration.
@export var mass := 1.0

## Radius in pixels which the agent tries to maintain.
@export var collision_radius := 30.0

## Limit of degree that the agent can turn in one frame.
@export_range(1, 90) var turning_radius := 90

## Maximum on force that can be applied to the agent before other forces are ignored.
@export var max_force := 0.5

## Maximum pixels that the agent can move in one frame.
@export var max_speed := 1

## Radius in pixel that other agents are detected.
@export var neighbor_radius := 100.0


@export var priority := 1

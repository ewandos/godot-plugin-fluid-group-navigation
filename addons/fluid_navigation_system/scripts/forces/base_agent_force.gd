@tool
class_name BaseForce
extends Node2D

@export var weight := 1.0
@export var debug_color := Color.DARK_MAGENTA

var steering_force := Vector2.ZERO

func calculate_force(agent: FluidAgentNavigation) -> Vector2:
	return Vector2.ZERO

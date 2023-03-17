@tool
class_name BaseForce
extends Node2D

@export var enabled := true
@export var weight := 1.0
@export var debug_color := Color.DARK_MAGENTA
@export var force := Vector2.ZERO

func get_force(agent: FluidAgentNavigation) -> Vector2:
	if not enabled: return Vector2.ZERO
	force = _calculate_force(agent) * weight
	return force

func _calculate_force(agent: FluidAgentNavigation) -> Vector2:
	return Vector2.ZERO

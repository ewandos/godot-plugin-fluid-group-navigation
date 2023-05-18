class_name Agent
extends Node2D

signal path_pushed(id: int, path: PackedVector2Array, current_position: Vector2)
signal path_resolved(id: int)
signal moved(id: int, position: Vector2)
signal calculated_velocity(id: int, velocity: Vector2)
signal collided(id: int)

var velocity := Vector2.ZERO
var heading := Vector2.RIGHT
var path := []

func calc_velocity() -> Vector2:
	return Vector2.ZERO

func set_destination(_target: Vector2, _append: bool = false) -> void:
	pass

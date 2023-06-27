class_name SolidObstaclesPlacer
extends Node2D

@export var blocked_cell_scene: PackedScene

func initialize(blocked_cells: PackedVector2Array) -> void:
	for child in get_children():
		child.queue_free()

	for cell in blocked_cells:
		var cell_global_position = cell * Vector2(64, 64)
		var solid_obstacle_instance := blocked_cell_scene.instantiate()
		solid_obstacle_instance.global_position = cell_global_position
		add_child(solid_obstacle_instance)

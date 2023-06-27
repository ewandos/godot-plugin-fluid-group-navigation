class_name RvoNavigationGrid
extends TileMap

var blocked_cells := PackedVector2Array():
	set = _set_blocked_cells

func _set_blocked_cells(value: PackedVector2Array) -> void:
	for cell in blocked_cells:
		set_cell(0, cell, 0, Vector2i(0, 0))
	blocked_cells = value
	for cell in blocked_cells:
		set_cell(0, cell, -1)

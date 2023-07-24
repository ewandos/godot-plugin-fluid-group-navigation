class_name Bresenham
extends Node

func get_cells_on_line(start: Vector2, end: Vector2) -> PackedVector2Array:

	var cells := PackedVector2Array()

	var x0 = start.x
	var y0 = start.y

	var x1 = end.x
	var y1 = end.y

	var dx = abs(x1 - x0)
	var dy = abs(y1 - y0)
	var sx = 1 if x0 < x1 else -1
	var sy = 1 if y0 < y1 else -1
	var err = dx - dy

	while true:
		cells.append(Vector2(x0, y0))

		if x0 == x1 and y0 == y1:
			break

		var e2 = 2 * err

		if e2 > -dy:
			err -= dy
			x0 += sx
		if e2 < dx:
			err += dx
			y0 += sy

	return cells

class_name Bresenham
extends Node

func sgn(x: int) -> int:
	if x > 0: return 1
	if x < 0: return -1
	return 0

func get_cells_on_line(start: Vector2, end: Vector2) -> PackedVector2Array:
	var cells := PackedVector2Array()

	var dx = end.x - start.x
	var dy = end.y - start.y

	var incx = sgn(dx)
	var incy = sgn(dy)
	if dx < 0: dx = -dx
	if dy < 0: dy = -dy

	var pdx
	var pdy
	var ddx
	var ddy
	var deltaslowdirection
	var deltafastdirection

	if dx < dy:
		pdx = incx
		pdy = 0
		ddx = incx
		ddy = incy
		deltaslowdirection = dy
		deltafastdirection = dx
	else:
		pdx = 0
		pdy = incy
		ddx = incx
		ddy = incy
		deltaslowdirection = dx
		deltafastdirection = dy

	var x = start.x
	var y = start.y
	var err = deltafastdirection / 2

	cells.append(Vector2(x, y))

	for t in deltafastdirection:
		err -= deltaslowdirection
		if err < 0:
			err += deltafastdirection
			x += ddx
			y += ddy
		else:
			x += pdx
			y += pdy
		cells.append(Vector2(x, y))

	return cells

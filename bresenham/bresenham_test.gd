class_name BresenhamTest
extends Node2D

@export var line_start := Vector2.ZERO
@export var line_end := Vector2.ONE * 5

var bresenham := Bresenham.new()
@onready var navigation_grid_2d := $NavigationGrid2D as NavigationGrid2D

func _ready() -> void:
	var cells: PackedVector2Array = bresenham.get_cells_on_line(line_start, line_end)
	print(cells)
	navigation_grid_2d.blocked_cells = cells
	queue_redraw()

func _draw() -> void:
	draw_line(line_start * navigation_grid_2d.cell_size.x, line_end * navigation_grid_2d.cell_size.x, Color.MAGENTA, 5)

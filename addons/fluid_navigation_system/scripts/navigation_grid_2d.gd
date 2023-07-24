@tool
class_name NavigationGrid2D
extends Node2D

@export var show_grid := true:
	set = _set_show_grid
@export var size := Vector2i(20, 20):
	set = _set_size
@export var cell_size := Vector2(64, 64):
	set = _set_cell_size
@export var offset := cell_size / 2
@export var blocked_cells := PackedVector2Array() :
	set = _set_blocked_cells
@export var grid_color := Color.WHEAT:
	set = _set_grid_color

var astar_grid: ThetaStarGrid

func _ready() -> void:
	astar_grid = ThetaStarGrid.new()
	astar_grid.size = size
	astar_grid.cell_size = cell_size
	astar_grid.offset = offset
	astar_grid.jumping_enabled = true
	astar_grid.diagonal_mode = ThetaStarGrid.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	astar_grid.update()

func calculate_path(from: Vector2, to: Vector2) -> PackedVector2Array:
	var from_id = (from / cell_size).floor()
	var to_id = (to / cell_size).floor()
	return astar_grid.calculate_path(from_id, to_id, true)

func _set_size(value: Vector2) -> void:
	size = value
	queue_redraw()

func _set_cell_size(value: Vector2) -> void:
	cell_size = value
	queue_redraw()

func _set_show_grid(value: bool) -> void:
	show_grid = value
	queue_redraw()

func _set_blocked_cells(value: PackedVector2Array) -> void:
	blocked_cells = value
	if not is_inside_tree(): await ready
	for cell in blocked_cells:
		astar_grid.set_point_solid(cell)
	queue_redraw()

func clear_grid() -> void:
	for cell in blocked_cells:
		astar_grid.set_point_solid(cell, false)
	queue_redraw()

func _set_grid_color(value: Color) -> void:
	grid_color = value
	queue_redraw()

func get_world_position(cell: Vector2i) -> Vector2:
	return Vector2(cell.x * cell_size.x + offset.x, cell.y * cell_size.y + offset.y)

func get_cell_position(world: Vector2) -> Vector2i:
	return (world / cell_size).floor()

func _draw() -> void:
	if not show_grid: return

	var board_height := size.y * cell_size.y
	var board_width := size.x * cell_size.x

	for i in size.x:
		draw_line(Vector2(i * cell_size.x, 0), Vector2(i * cell_size.x, board_height), grid_color)

	for i in size.y:
		draw_line(Vector2(0, i * cell_size.y), Vector2(board_width, i * cell_size.y, ), grid_color)

	draw_line(Vector2(board_width, 0), Vector2(board_width, board_height), grid_color)
	draw_line(Vector2(0, board_height), Vector2(board_width, board_height), grid_color)

	for cell in blocked_cells:
		var cell_rect = Rect2(cell.x * cell_size.x, cell.y * cell_size.y, cell_size.x, cell_size.y)
		draw_rect(cell_rect, grid_color)





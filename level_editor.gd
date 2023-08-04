class_name LevelEditor
extends Node2D

enum TYPE { BLOCKED_CELL, UNIT_SPAWN }

@onready var navigation_grid := $NavigationGrid2D as NavigationGrid2D
@onready var ui := $UI
@onready var load_map_ui := $UI/LoadMap
@onready var save_map_ui := $UI/SaveMap

var selected_type := TYPE.BLOCKED_CELL
var blocked_cells := PackedVector2Array()
var unit_routes := {}
var current_unit_route := PackedVector2Array()

func _ready() -> void:
	ui.visible = false

func _input(event: InputEvent) -> void:
	queue_redraw()
	if event is InputEventMouseButton and event.pressed and not ui.visible:
		var cell_position = navigation_grid.get_cell_position(event.position)

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			selected_type = (selected_type + 1) % TYPE.size()
			print(selected_type)

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			selected_type = (selected_type - 1) % TYPE.size()
			print(selected_type)

		if selected_type == TYPE.UNIT_SPAWN:
			if event.button_index == MOUSE_BUTTON_LEFT:
				current_unit_route.append(cell_position)
				if current_unit_route.size() == 2:
					unit_routes[current_unit_route[0]] = current_unit_route[1]
					current_unit_route.clear()

			if event.button_index == MOUSE_BUTTON_RIGHT:
				unit_routes.erase(cell_position as Vector2)

		if selected_type == TYPE.BLOCKED_CELL:
			if event.button_index == MOUSE_BUTTON_LEFT:
				var already_set = blocked_cells.find(cell_position) != -1
				if already_set: return
				blocked_cells.append(cell_position)
				navigation_grid.blocked_cells = blocked_cells

			if event.button_index == MOUSE_BUTTON_RIGHT:
				var index_to_remove = blocked_cells.find(cell_position)
				if index_to_remove == -1: return
				blocked_cells.remove_at(index_to_remove)
				navigation_grid.blocked_cells = blocked_cells

	if event.is_action_pressed('ui_cancel'):
		ui.visible = !ui.visible


func _on_save_map_input_clicked_save_map(map_name: String) -> void:
	var map = Map.new()
	map.name = map_name
	map.blocked_cells = blocked_cells
	map.unit_spawns = unit_routes.keys()
	map.unit_targets = unit_routes.values()
	ResourceSaver.save(map, 'res://maps/' + map_name + '.tres')
	_reset()

func _on_load_map_clicked_load_map(map_name) -> void:
	_reset()
	var map := ResourceLoader.load('res://maps/' + map_name) as Map
	blocked_cells = map.blocked_cells
	navigation_grid.blocked_cells = map.blocked_cells
	for i in map.unit_spawns.size():
		unit_routes[map.unit_spawns[i]] = map.unit_targets[i]
	save_map_ui.set_map_name(map.name)

func _reset() -> void:
	navigation_grid.blocked_cells = []
	blocked_cells = PackedVector2Array()
	unit_routes.clear()
	current_unit_route.clear()
	ui.visible = false


func _draw() -> void:
	draw_line(Vector2(navigation_grid.size.x / 2 * navigation_grid.cell_size.x, 0), Vector2(navigation_grid.size.x / 2 * navigation_grid.cell_size.x, navigation_grid.size.y * navigation_grid.cell_size.y), Color.BLACK, 5)
	draw_line(Vector2(0, navigation_grid.size.y / 2 * navigation_grid.cell_size.y), Vector2(navigation_grid.size.x * navigation_grid.cell_size.x, navigation_grid.size.y / 2 * navigation_grid.cell_size.y), Color.BLACK, 5)

	if current_unit_route.size() == 1:
		var start_point = navigation_grid.get_world_position(current_unit_route[0])
		draw_circle(start_point, 10, Color.MAGENTA)

	var index := 0
	for route_cell in unit_routes:
		var start_position = navigation_grid.get_world_position(route_cell)
		var end_position = navigation_grid.get_world_position(unit_routes[route_cell])
		draw_dashed_line(start_position, end_position, Color.MAGENTA, 10, 5)

		var default_font = ThemeDB.fallback_font
		var default_font_size = ThemeDB.fallback_font_size
		index += 1
		draw_string(default_font, start_position, var_to_str(index), HORIZONTAL_ALIGNMENT_LEFT, -1, default_font_size * 4, Color.MAGENTA)

extends Node2D


signal completed_test
enum Directions {LEFT, RIGHT, TOP, BOTTOM}

@export_range(1, 20) var random_iterations := 10
@export_range(1, 100) var random_blocked_cells := 10
@export_range(1, 20) var agent_count := 5
@export var test_margin := 4
@export var predefined_maps: Array[PackedVector2Array] = []
@export var agent: PackedScene
@onready var navigation_grid := $NavigationGrid2D as NavigationGrid2D

var test_index := 0

# per test vars
var completed_paths := 0
var agents := []

func _ready() -> void:
	completed_test.connect(_on_completed_test)
	randomize()
	initialize_test()

func initialize_test() -> void:
	var should_use_predefined_maps: bool = test_index < predefined_maps.size()
	var should_use_random_map: bool = not should_use_predefined_maps and test_index < (predefined_maps.size() + random_iterations)
	if should_use_predefined_maps:
		navigation_grid.blocked_cells = predefined_maps[test_index]
	elif should_use_random_map:

		# place random blocked cells
		var blocked_cells := PackedVector2Array()
		for i in random_blocked_cells:
			var random_x = randi_range(test_margin, navigation_grid.size.x - test_margin - 1)
			var random_y = randi_range(test_margin, navigation_grid.size.y - test_margin - 1)
			blocked_cells.append(Vector2(random_x, random_y))

		navigation_grid.blocked_cells = blocked_cells

	# place random units
	for i in agent_count:
		var starting_direction = i % Directions.keys().size()
		var target_direction = (starting_direction + 2) % Directions.keys().size()
		var starting_cell = _get_random_cell_on_border(starting_direction)
		var target_cell = _get_random_cell_on_border(target_direction)

		var start_world_position = navigation_grid.get_world_position(starting_cell)
		var target_world_position = navigation_grid.get_world_position(target_cell)

		var agent_instance = agent.instantiate() as Unit
		agent_instance.global_position = start_world_position
		agent_instance.move_to(target_world_position)
		agent_instance.reached_target.connect(_on_reached_target)
		add_child(agent_instance)

	test_index += 1
	print('Initialization for test #', test_index, ' completed.')

func _on_reached_target() -> void:
	completed_paths += 1
	print('Unit completed path.')

	if agent_count == completed_paths:
		completed_test.emit()

func _on_completed_test() -> void:
	print('Completed test #' , test_index, '.')

func _get_random_cell_on_border(direction: Directions) -> Vector2i:
	var random_x := 0
	var random_y := 0
	if direction == Directions.LEFT:
		random_x = randi_range(0, test_margin - 1)
		random_y = randi_range(0, navigation_grid.size.y - 1)
	elif direction == Directions.RIGHT:
		random_x = randi_range(navigation_grid.size.x - test_margin, navigation_grid.size.x - 1)
		random_y = randi_range(0, navigation_grid.size.y - 1)
	elif direction == Directions.TOP:
		random_x = randi_range(test_margin, navigation_grid.size.x - test_margin - 1)
		random_y = randi_range(0, test_margin - 1)
	elif direction == Directions.BOTTOM:
		random_x = randi_range(test_margin, navigation_grid.size.x - test_margin - 1)
		random_y = randi_range(navigation_grid.size.y - test_margin, navigation_grid.size.y - 1)
	return Vector2i(random_x, random_y)

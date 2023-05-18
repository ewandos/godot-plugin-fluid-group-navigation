extends Node2D


signal completed_suite
enum Directions {TOP, RIGHT, BOTTOM, LEFT}

@export var export_data := false
@export_range(1, 20) var random_iterations := 10
@export_range(0, 100) var random_blocked_cells := 10
@export_range(1, 20) var agent_count := 5
@export var test_margin := 4
@export var predefined_maps: Array[Map] = []
@export var unit: PackedScene

@onready var navigation_grid := $NavigationGrid2D as NavigationGrid2D
@onready var path_renderer := $PathRenderer as PathRenderer

var test_index := 0
var test_hash: int = Time.get_datetime_string_from_system().hash()

var units: Array[Unit] = []
var data_crawler: DataCrawler

func _ready() -> void:
	randomize()
	seed(1602)
	initialize_test()

func initialize_test() -> void:
	var should_use_predefined_maps: bool = test_index < predefined_maps.size()
	var should_use_random_map: bool = not should_use_predefined_maps and test_index < (predefined_maps.size() + random_iterations)
	var test_id: String

	if should_use_predefined_maps:
		var map: Map = predefined_maps[test_index]

		navigation_grid.blocked_cells = map.blocked_cells

		for i in map.unit_spawns.size():
			var starting_cell = map.unit_spawns[i]
			var target_cell = map.unit_targets[i]

			var start_world_position = navigation_grid.get_world_position(starting_cell)
			var target_world_position = navigation_grid.get_world_position(target_cell)

			var unit_instance = unit.instantiate() as Unit
			units.append(unit_instance)
			unit_instance.global_position = start_world_position
			unit_instance.move_to(target_world_position)
			add_child(unit_instance)

		test_id = var_to_str(test_hash) + '_' + var_to_str(test_index) + '_' + map.name

	elif should_use_random_map:

		test_id =  var_to_str(test_hash) + '_' + var_to_str(test_index)

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

			var unit_instance = unit.instantiate()
			units.append(unit_instance)
			unit_instance.global_position = start_world_position
			unit_instance.move_to(target_world_position)
			add_child(unit_instance)


	if export_data: data_crawler = DataCrawler.new()
	add_child(data_crawler)


	var agents: Array[Agent] = []
	for unit in units:
		agents.append(unit.movement)

	data_crawler.initialize(test_id, agents)
	data_crawler.all_agents_have_completed.connect(_on_all_agents_have_completed)

	path_renderer.initialize(agents)


	print('Initialization for test #', test_index, ' completed.')

func _on_all_agents_have_completed() -> void:
	print('Completed test #' , test_index, '.')

	if export_data:
		data_crawler.export_data()
		data_crawler.queue_free()

	navigation_grid.clear_grid()

	for unit in units:
		unit.queue_free()

	units.clear()

	test_index += 1

	if test_index >= predefined_maps.size() + random_iterations:
		completed_suite.emit()
	else:
		initialize_test()

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

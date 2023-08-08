extends Node2D

signal completed_suite
enum Directions {TOP, RIGHT, BOTTOM, LEFT}

@export var export_data := DataExport.DETAILED

@export_range(1, 20) var random_iterations := 10
@export_range(0, 315) var random_blocked_cells := 10
@export_range(1, 20) var agent_count := 5
@export var test_margin := 4
@export var predefined_maps: Array[Map] = []
@export var unit: PackedScene

@onready var navigation_grid := $NavigationGrid2D as NavigationGrid2D
@onready var rvo_navigation_grid := $RvoNavigationGrid as RvoNavigationGrid
@onready var path_renderer := $PathRenderer as PathRenderer
@onready var breadcrumps_renderer := $BreadcrumpsRenderer as BreadcrumpsRenderer

var test_index := 0
var test_hash: int = Time.get_datetime_string_from_system().hash()
const NOT_FOUND = -1
var random_seed := 1602

var units: Array[Unit] = []
var data_crawler: DataCrawler

enum DataExport {
	NONE,
	DETAILED,
	MEANS
}

func _ready() -> void:
	randomize()
	seed(random_seed)
	initialize_test()

func initialize_test() -> void:
	var should_use_predefined_maps: bool = test_index < predefined_maps.size()
	var should_use_random_map: bool = not should_use_predefined_maps and test_index < (predefined_maps.size() + random_iterations)
	var test_id: String
	var test_attributes := TestAttributes.new()

	test_attributes.agent_name = unit._bundled['names'][0]

	if should_use_predefined_maps:
		var map: Map = predefined_maps[test_index]

		navigation_grid.blocked_cells = map.blocked_cells
		rvo_navigation_grid.blocked_cells = map.blocked_cells

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

		test_id = var_to_str(test_hash)

		test_attributes.map_name = map.name
		test_attributes.blocked_cells_count = map.blocked_cells.size()

	elif should_use_random_map:

		var starting_cells := []
		var target_cells := []

		test_id = var_to_str(test_hash)

		# place random blocked cells
		var blocked_cells := PackedVector2Array()
		for i in random_blocked_cells:
			var random_x = randi_range(test_margin, navigation_grid.size.x - test_margin - 1)
			var random_y = randi_range(test_margin, navigation_grid.size.y - test_margin - 1)
			blocked_cells.append(Vector2(random_x, random_y))

		navigation_grid.blocked_cells = blocked_cells
		rvo_navigation_grid.blocked_cells = blocked_cells

		test_attributes.blocked_cells_count = blocked_cells.size()
		test_attributes.seed = random_seed
		test_attributes.iteration = test_index

		# place random units
		for i in agent_count:
			var starting_direction = i % Directions.keys().size()
			var target_direction = (starting_direction + 2) % Directions.keys().size()

			var starting_cell = _get_random_cell_on_border(starting_direction)
			while starting_cells.find(starting_cell) != NOT_FOUND:
				starting_cell = _get_random_cell_on_border(starting_direction)
			starting_cells.append(starting_cell)

			var target_cell = _get_random_cell_on_border(target_direction)
			while target_cells.find(target_cell) != NOT_FOUND:
				target_cell = _get_random_cell_on_border(target_direction)
			target_cells.append(target_cell)

			var start_world_position = navigation_grid.get_world_position(starting_cell)
			var target_world_position = navigation_grid.get_world_position(target_cell)

			var unit_instance = unit.instantiate()
			units.append(unit_instance)
			unit_instance.global_position = start_world_position
			unit_instance.move_to(target_world_position)
			add_child(unit_instance)

	var agents: Array[Agent] = []
	for unit in units:
		agents.append(unit.movement)

	if export_data:
		data_crawler = DataCrawler.new()
		test_attributes.test_id = test_id
		test_attributes.agents = agents
		test_attributes.map_size = navigation_grid.size
		test_attributes.agent_count = agents.size()
		test_attributes.cells_density = navigation_grid.get_cells_density()

		data_crawler.initialize(test_attributes)
		data_crawler.all_agents_have_completed.connect(_on_all_agents_have_completed)
		add_child(data_crawler)

	path_renderer.initialize(agents)
	breadcrumps_renderer.initialize(agents)


	print('Initialization for test #', test_index, ' completed.')

func _on_all_agents_have_completed() -> void:
	print('Completed test #' , test_index, '.')

	if export_data != DataExport.NONE:

		if export_data == DataExport.DETAILED:
			data_crawler.export_data_detailed()
		elif export_data == DataExport.MEANS:
			data_crawler.export_data_means()
		data_crawler.queue_free()

	navigation_grid.clear_grid()

	for unit in units:
		unit.queue_free()

	units.clear()

	test_index += 1

	if test_index >= predefined_maps.size() + random_iterations:
		completed_suite.emit()
		get_tree().quit()
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
	var random_position = Vector2i(random_x, random_y)



	return random_position

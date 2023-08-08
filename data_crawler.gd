class_name DataCrawler
extends Node

signal all_agents_have_completed

var _test_attributes: TestAttributes
var snap_unit := 0.00001
var movement_infos := {}
var agent_ids : Array[int] = []

func _init() -> void:
	set_process(false)

func initialize(test_attributes: TestAttributes) -> void:
	_test_attributes = test_attributes

	movement_infos.clear()
	agent_ids.clear()

	for agent in _test_attributes.agents:
		movement_infos[agent.get_instance_id()] = MovementInfo.new()

		if agent.path.size() == 0: await agent.path_pushed
		movement_infos[agent.get_instance_id()].path = agent.path

		agent.path_pushed.connect(_on_agent_path_pushed)
		agent.calculated_velocity.connect(_on_calculated_velocity)
		agent.path_resolved.connect(_on_agent_path_resolved)
		agent.collided.connect(_on_agent_collided)
		agent.moved.connect(_on_agent_moved)

	set_process(true)

func _process(delta: float) -> void:
	var running_agents := 0

	for movement in movement_infos.values():
		if movement.is_completed: continue
		movement.time_in_ms += delta
		running_agents += 1

	if running_agents == 0:
		all_agents_have_completed.emit()
		set_process(false)

func _on_agent_path_resolved(id: int) -> void:
	print('Agent #', id, ' resolved path.')
	movement_infos[id].is_completed = true

func _on_calculated_velocity(id: int, velocity: Vector2) -> void:
	movement_infos[id].velocities.append(velocity)

func _on_agent_collided(id: int) -> void:
	movement_infos[id].collision_count += 1

func _on_agent_moved(id: int, position: Vector2) -> void:
	movement_infos[id].positions.append(position)

func _on_agent_path_pushed(id: int, path: PackedVector2Array, current_position: Vector2) -> void:
	if movement_infos[id].path != null:
		movement_infos[id].path = path

func export_data_detailed() -> void:
	var screenshot_image: Image = get_viewport().get_texture().get_image()
	screenshot_image.save_jpg('res://../_logs/' + _test_attributes.test_id + '.jpg')

	var file_name = _test_attributes.test_id + '.csv'
	var file = FileAccess.open('res://../_logs/' + file_name, FileAccess.WRITE)
	file.store_csv_line(['agent_id', 'calculated_path_length', 'traveled_path_length', 'path_lengths_diff', 'completion_time', 'mean_velocity', 'velocity_standard_deviation', 'collision_count'], ';')

	var summed_calculated_path_lengths := 0.0
	var summed_traveled_path_lengths := 0.0
	var summed_path_lengths_diff := 0.0
	var summed_completion_times_in_ms := 0.0
	var summed_mean_velocity := 0.0
	var summed_velocity_standard_deviations := 0.0
	var summed_collision_count := 0.0

	for agent_id in movement_infos.keys():
		var calculated_path_length: float = movement_infos[agent_id].get_path_length()
		var traveled_path_length: float = movement_infos[agent_id].get_traveled_path_length()
		var path_lengths_diff: float = traveled_path_length - calculated_path_length
		var completion_time_in_ms: float = movement_infos[agent_id].time_in_ms
		var mean_velocity: float = movement_infos[agent_id].get_velocity_mean()
		var velocity_standard_deviation: float = movement_infos[agent_id].get_velocity_standard_deviation()
		var collision_count: float = movement_infos[agent_id].collision_count

		summed_calculated_path_lengths += calculated_path_length
		summed_traveled_path_lengths += traveled_path_length
		summed_path_lengths_diff += path_lengths_diff
		summed_completion_times_in_ms += completion_time_in_ms
		summed_mean_velocity += mean_velocity
		summed_velocity_standard_deviations += velocity_standard_deviation
		summed_collision_count += collision_count

		file.store_csv_line([agent_id, snappedf(calculated_path_length, snap_unit), snappedf(traveled_path_length, snap_unit), snappedf(path_lengths_diff, snap_unit), snappedf(completion_time_in_ms, snap_unit), snappedf(mean_velocity, snap_unit), snappedf(velocity_standard_deviation, snap_unit), collision_count], ';')

	var mean_path_lengths := summed_calculated_path_lengths / movement_infos.size()
	var mean_traveled_path_lengths := summed_traveled_path_lengths / movement_infos.size()
	var mean_path_lengths_diffs := summed_path_lengths_diff / movement_infos.size()
	var mean_completion_times_in_ms := summed_completion_times_in_ms / movement_infos.size()
	var mean_mean_velocity := summed_mean_velocity / movement_infos.size()
	var mean_velocity_standard_deviations := summed_velocity_standard_deviations / movement_infos.size()
	var mean_collision_count := summed_collision_count / movement_infos.size()

	file.store_csv_line([])
	file.store_csv_line(['mean', snappedf(mean_path_lengths, snap_unit), snappedf(mean_traveled_path_lengths, snap_unit), snappedf(mean_path_lengths_diffs, snap_unit), snappedf(mean_completion_times_in_ms, snap_unit), snappedf(mean_mean_velocity, snap_unit), snappedf(mean_velocity_standard_deviations, snap_unit), snappedf(mean_collision_count, snap_unit)], ';')


func export_data_means() -> void:

	## Calculations

	var summed_calculated_path_lengths := 0.0
	var summed_traveled_path_lengths := 0.0
	var summed_path_lengths_diff := 0.0
	var summed_completion_times_in_ms := 0.0
	var summed_mean_velocity := 0.0
	var summed_velocity_standard_deviations := 0.0
	var summed_collision_count := 0.0

	for agent_id in movement_infos.keys():
		var calculated_path_length: float = movement_infos[agent_id].get_path_length()
		var traveled_path_length: float = movement_infos[agent_id].get_traveled_path_length()
		var path_lengths_diff: float = traveled_path_length - calculated_path_length
		var completion_time_in_ms: float = movement_infos[agent_id].time_in_ms
		var mean_velocity: float = movement_infos[agent_id].get_velocity_mean()
		var velocity_standard_deviation: float = movement_infos[agent_id].get_velocity_standard_deviation()
		var collision_count: float = movement_infos[agent_id].collision_count

		summed_calculated_path_lengths += calculated_path_length
		summed_traveled_path_lengths += traveled_path_length
		summed_path_lengths_diff += path_lengths_diff
		summed_completion_times_in_ms += completion_time_in_ms
		summed_mean_velocity += mean_velocity
		summed_velocity_standard_deviations += velocity_standard_deviation
		summed_collision_count += collision_count

	var mean_path_lengths := summed_calculated_path_lengths / movement_infos.size()
	var mean_traveled_path_lengths := summed_traveled_path_lengths / movement_infos.size()
	var mean_path_lengths_diffs := summed_path_lengths_diff / movement_infos.size()
	var mean_completion_times_in_ms := summed_completion_times_in_ms / movement_infos.size()
	var mean_mean_velocity := summed_mean_velocity / movement_infos.size()
	var mean_velocity_standard_deviations := summed_velocity_standard_deviations / movement_infos.size()
	var mean_collision_count := summed_collision_count / movement_infos.size()


	var percentage_of_blocked_cells := (_test_attributes.blocked_cells_count / (_test_attributes.map_size.x * _test_attributes.map_size.y)) * 100
	## Export

	var iteration_id: String = (var_to_str(_test_attributes.seed) + '_' + var_to_str(_test_attributes.iteration)) if _test_attributes.seed != null else _test_attributes.map_name

	var screenshot_image: Image = get_viewport().get_texture().get_image()
	screenshot_image.save_jpg('res://../_logs/' + _test_attributes.test_id + '_' + iteration_id + '.jpg')
#

	var file_name = _test_attributes.agent_name + '.csv'
	var path = 'res://../_logs/' + file_name
	var file_exists_already := FileAccess.file_exists(path)
	var file: FileAccess

	if not file_exists_already:
		file = FileAccess.open('res://../_logs/' + file_name, FileAccess.WRITE)
		file.store_csv_line([
			'test_id',
			'iteration_id',
			'percentage_of_blocked_cells',
			'cell_density',
			'agent_count',
			'mean_calculated_path_length',
			'mean_traveled_path_lengths',
			'mean_path_lengths_diffs',
			'mean_mean_velocity',
			'mean_velocity_standard_deviations',
			'mean_collision_count'
		], ';')
	else:
		file =  FileAccess.open('res://../_logs/' + file_name, FileAccess.READ_WRITE)
		file.seek_end()

	file.store_csv_line([
		_test_attributes.test_id,
		iteration_id,
		snappedf(percentage_of_blocked_cells, snap_unit),
		snappedf(_test_attributes.cells_density, snap_unit),
		_test_attributes.agent_count,
		snappedf(mean_path_lengths, snap_unit),
		snappedf(mean_traveled_path_lengths, snap_unit),
		snappedf(mean_path_lengths_diffs, snap_unit),
		snappedf(mean_mean_velocity, snap_unit),
		snappedf(mean_velocity_standard_deviations, snap_unit),
		snappedf(mean_collision_count, snap_unit)
	], ';')

	file.close()

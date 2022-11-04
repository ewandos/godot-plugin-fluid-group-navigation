extends Node

func calculate_path(start_position: Vector2, target_position: Vector2) -> PackedVector2Array:
	var parameter := NavigationPathQueryParameters2D.new()
	parameter.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL
	parameter.start_position = start_position
	parameter.target_position = target_position
	parameter.map = NavigationServer2D.get_maps()[0]
	var query_result := NavigationPathQueryResult2D.new()
	NavigationServer2D.query_path(parameter, query_result)
	var result := query_result.get_path()
	result.remove_at(0)
	return result

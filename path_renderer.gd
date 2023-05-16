class_name PathRenderer
extends Node2D

@export var visible_path := true

var _agents: Array[Agent] = []
var _paths := {}

func initialize(agents: Array[Agent]):
	_agents.clear()
	_paths.clear()
	_agents = agents
	for agent in _agents:
		show_path(agent.get_instance_id(), agent.path, agent.global_position)

func show_path(id: int, path: PackedVector2Array, starting_position: Vector2):
	path.insert(0, starting_position)
	_paths[id] = path
	queue_redraw()

func _draw():
	if (!visible_path || _paths.size() == 0): return
	for key in _paths:
		if (_paths[key].size() < 2): continue
		draw_polyline(_paths[key], Color.MAGENTA, 1, true)
		for point in _paths[key]:
			draw_circle(point, 5, Color.MAGENTA)

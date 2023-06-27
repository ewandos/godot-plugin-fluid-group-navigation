class_name BreadcrumpsRenderer
extends Node2D

var agent_breadcrumps := {}

func initialize(agents: Array[Agent]):
	agent_breadcrumps.clear()
	for agent in agents:
		agent.moved.connect(_on_moved)
		agent_breadcrumps[agent.get_instance_id()] = PackedVector2Array()

func _on_moved(agent_id: int, position: Vector2) -> void:
	agent_breadcrumps[agent_id].append(position)
	queue_redraw()

func _draw() -> void:
	for agent_breadcrump in agent_breadcrumps.values():
		if agent_breadcrump.size() < 2: continue
		draw_polyline(agent_breadcrump, Color.WHITE, 2)

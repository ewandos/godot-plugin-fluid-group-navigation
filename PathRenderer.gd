extends Node2D

@onready var units = []

func _ready():
	units = get_tree().get_nodes_in_group("unit")
	for unit in units:
		unit.agent.path_changed.connect(queue_redraw)

func _draw():
	for unit in units:
		if (unit.agent.get_nav_path().size() < 2): return
		draw_polyline(unit.agent.get_nav_path(), Color.MAGENTA, 5)

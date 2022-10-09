extends Node2D

@onready var units = []

func _ready():
	units = get_tree().get_nodes_in_group("unit")
	for unit in units:
		unit.connect("path_changed", queue_redraw)

func _draw():
	for unit in units:
		if unit.result.path.size() < 2: return
		draw_polyline(unit.result.path, Color.MAGENTA, 5)

extends Node2D

@export var visible_path := true

var units := []
var paths := {}

func _ready():
	units = get_tree().get_nodes_in_group("agent")
	for unit in units:
		unit.path_pushed.connect(show_path)

func show_path(id: int, path: PackedVector2Array):
	paths[id] = path
	queue_redraw()

func _draw():
	if (!visible_path || paths.size() == 0): return
	for key in paths.keys():
		if (paths[key].size() < 2): continue
		draw_polyline(paths[key], Color.MAGENTA, 5)

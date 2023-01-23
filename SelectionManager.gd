# THIS WON'T BE PART OF THE PLUGIN

extends Node
class_name SelectionManager

var selection := []

func set_selection(new_selection):
	selection = new_selection

func existing_selection() -> bool:
	return selection.size() != 0

func get_centroid() -> Vector2:
	var centroid := Vector2.ZERO
	for obj in selection:
		centroid += obj.global_position
	centroid /= selection.size()
	return centroid

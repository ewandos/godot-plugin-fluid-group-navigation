extends Node2D

var units: Array
var markers: Array


func _ready() -> void:
	units = find_children("*", "Unit")
	markers = find_children("*", "Marker2D")

func _on_button_pressed() -> void:
	var i := 0
	for unit in units:
		unit.movement.set_target(markers[i].global_position)
		i += 1


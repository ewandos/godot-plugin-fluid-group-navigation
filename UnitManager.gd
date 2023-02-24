# THIS WON'T BE PART OF THE PLUGIN

extends Node
class_name UnitManager

@onready var selection_manager := $SelectionManager
@onready var selector := $Selector

func _ready():
	selector.connect("selection_finished", selection_manager.set_selection)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selection_manager.existing_selection():
		var selection_centroid = selection_manager.get_centroid()

		for obj in selection_manager.selection:
			var offset = obj.global_position - selection_centroid
			var target_position = get_viewport().get_mouse_position() + offset
			obj.movement.set_destination(target_position)

func set_selection(selection):
	selection_manager.selection = selection

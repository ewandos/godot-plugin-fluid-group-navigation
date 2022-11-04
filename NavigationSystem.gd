extends Node
class_name NavigationSystem

@onready var selection_manager := $SelectionManager
@onready var unit_selector := $UnitSelector

func _ready():
	unit_selector.connect("selection_finished", selection_manager.set_selection)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and selection_manager.existing_selection():
		var selection_centroid = selection_manager.get_centroid()
		
		for obj in selection_manager.selection:
			var offset = obj.global_position - selection_centroid
			var target_position = get_viewport().get_mouse_position() + offset
			var path = Pathfinder2d.calculate_path(obj.global_position, target_position)
			obj.movement.set_path(path)

func set_selection(selection):
	selection_manager.selection = selection

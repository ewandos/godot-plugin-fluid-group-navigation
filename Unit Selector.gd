extends Node2D

var dragging := false
var selected_units := []
var drag_start = Vector2.ZERO
var select_rectangle = RectangleShape2D.new()

func _input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		if event.pressed:
			for unit in selected_units:
				unit.collider.deselect();
			selected_units = []
			dragging = true
			drag_start = event.position
		elif dragging:
			dragging = false
			var drag_end = event.position
			select_rectangle.extents = (drag_end - drag_start) / 2
			var space = get_world_2d().direct_space_state
			var query = Physics2DShapeQueryParameters.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0, (drag_end + drag_start) / 2)
			selected_units = space.intersect_shape(query)
			for unit in selected_units:
				unit.collider.select()

extends Node2D

@export var color: Color

var dragging := false
var selected_units := []
var drag_start := Vector2.ZERO
var drag_end := Vector2.ZERO
var select_rectangle := RectangleShape2D.new()

func _ready():
	hide()

func _input(event):
	if event is InputEventMouseMotion and dragging:
		drag_end = event.position
		select_rectangle.extents = abs(drag_end - drag_start) / 2
		queue_redraw()
		show()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			dragging = true
			drag_start = event.position
			
		# mouse button event fires on press and release
		elif dragging:
			dragging = false
			for unit in selected_units:
				unit.collider.deselect();
			selected_units = []
			var space = get_world_2d().direct_space_state
			var query = PhysicsShapeQueryParameters2D.new()
			query.set_shape(select_rectangle)
			query.transform = Transform2D(0, (drag_end + drag_start) / 2)
			query.collide_with_areas = true
			selected_units = space.intersect_shape(query)
			for unit in selected_units:
				unit.collider.select()
			_reset()

func _draw() -> void:
	var rect = Rect2(drag_start, drag_end - drag_start)
	draw_rect(rect, color)

func _reset() -> void:
	drag_start = Vector2.ZERO
	drag_end = Vector2.ZERO
	select_rectangle.extents = Vector2.ZERO
	hide()
	queue_redraw()

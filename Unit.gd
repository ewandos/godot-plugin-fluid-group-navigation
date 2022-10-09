extends CharacterBody2D
class_name Unit

@export var color: Color
signal path_changed
var is_selected := false
var result := NavigationPathQueryResult2D.new()

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_selected:
		var parameter := NavigationPathQueryParameters2D.new()
		parameter.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL
		parameter.start_position = position
		parameter.target_position = get_viewport().get_mouse_position()
		parameter.map = NavigationServer2D.get_maps()[0]
		
		NavigationServer2D.query_path(parameter, result)
		print(result.path)
		path_changed.emit()
		
func _physics_process(delta: float) -> void:
	pass

func select() -> void:
	sprite.modulate = color
	is_selected = true
	
func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

extends Area2D
class_name Unit

@export var color: Color
@export var speed: float = 1.0
var is_selected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2d

var result := []

func _ready() -> void:
	pass

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_selected:
		var parameter := NavigationPathQueryParameters2D.new()
		parameter.path_postprocessing = NavigationPathQueryParameters2D.PATH_POSTPROCESSING_CORRIDORFUNNEL
		parameter.start_position = position
		parameter.target_position = get_viewport().get_mouse_position()
		parameter.map = NavigationServer2D.get_maps()[0]
		var query_result := NavigationPathQueryResult2D.new()
		NavigationServer2D.query_path(parameter, query_result)
		result = query_result.get_path()
		result.remove_at(0)
		print(result)
		
func _physics_process(delta: float) -> void:
	if (result.size() == 0): return
	var next_location = result[0]
	var distance = global_position.distance_to(next_location)
	
	if (distance <= 10):
		result.remove_at(0)
	
	var v = (next_location - global_position).normalized() * speed
	position += v

func select() -> void:
	sprite.modulate = color
	is_selected = true
	
func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

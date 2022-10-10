extends Area2D
class_name Unit

@export var color: Color
@export var speed: float = 1.0
var is_selected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2d

func _ready() -> void:
	agent.velocity_computed.connect(on_velocity_computed)
	agent.path_changed.connect(on_path_changed)
	agent.target_reached.connect(on_target_reached)

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and is_selected:
		agent.set_target_location(get_viewport().get_mouse_position())
		
func _physics_process(delta: float) -> void:
	if (agent.get_target_location() == Vector2.ZERO): return
	var next_location = agent.get_next_location()
	var v = (next_location - global_position).normalized()
	agent.set_velocity(v * speed)

func on_velocity_computed(safe_velocity: Vector2) -> void:
	position += safe_velocity

func on_path_changed() -> void:
	pass

func on_target_reached() -> void:
	print("reached goal")

func select() -> void:
	sprite.modulate = color
	is_selected = true
	
func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

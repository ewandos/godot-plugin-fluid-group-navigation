## This is a wrapper for the NavigationAgent2D

class_name AgentWrapper
extends Agent

@export var movement_speed: float = 4.0
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D

var velocity := Vector2.ZERO
var path := []

func _ready() -> void:
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.target_reached.connect(func(): path_resolved.emit(get_instance_id()))
	navigation_agent.path_changed.connect(func(): path = navigation_agent.get_current_navigation_path())


func move_to(movement_target: Vector2):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):
	if navigation_agent.is_navigation_finished():
		return

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_speed
	navigation_agent.set_velocity(new_velocity)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	calculated_velocity.emit(get_instance_id(), safe_velocity)
	moved.emit(get_instance_id(), global_position)

func calc_velocity() -> Vector2:
	return velocity

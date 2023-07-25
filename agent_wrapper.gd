## This is a wrapper for the NavigationAgent2D

class_name AgentWrapper
extends Agent

@export var movement_speed: float = 100
@onready var navigation_agent := $NavigationAgent2D as NavigationAgent2D

var is_moving := false
var heading_smoother := HeadingSmoother.new(10)

func _ready() -> void:
	heading = heading.rotated(global_rotation)
	navigation_agent.velocity_computed.connect(_on_velocity_computed)
	navigation_agent.path_changed.connect(_on_path_changed)
	navigation_agent.navigation_finished.connect(func(): path_resolved.emit(get_instance_id()))

func set_destination(movement_target: Vector2, append: bool = false):
	navigation_agent.set_target_position(movement_target)

func _physics_process(delta):

	var next_path_position: Vector2 = navigation_agent.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_speed
	navigation_agent.set_velocity(new_velocity)

func _on_path_changed() -> void:
	path = navigation_agent.get_current_navigation_path()
	path_pushed.emit(get_instance_id(), path, global_position)

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	heading = heading_smoother.update(velocity.normalized())
	calculated_velocity.emit(get_instance_id(), safe_velocity)
	moved.emit(get_instance_id(), global_position)

func calc_velocity() -> Vector2:
	return velocity

func _on_collision_check_body_entered(body: Node2D) -> void:
	if not body is Unit or body == get_parent(): return
	collided.emit(get_instance_id())

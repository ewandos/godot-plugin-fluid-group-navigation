extends CharacterBody2D
class_name Unit

@export var color: Color
var is_selected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var movement: FluidAgentNavigation = $AgentMovement

func _physics_process(_delta):
	velocity = movement.calc_velocity() * 100
	sprite.look_at(global_position + movement.heading)
	move_and_slide()

func select() -> void:
	sprite.modulate = color
	is_selected = true

func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

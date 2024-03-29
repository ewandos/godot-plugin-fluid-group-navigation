extends CharacterBody2D
class_name Unit

@export var color: Color
var is_selected := false

@export var speed_modifier := 1
@onready var sprite: Sprite2D = $Sprite2D
@onready var movement := $AgentMovement as Agent

func _physics_process(_delta):
	velocity = movement.calc_velocity() * speed_modifier
	sprite.look_at(global_position + movement.heading)
	move_and_slide()

func move_to(position: Vector2) -> void:
	if not is_inside_tree(): await ready
	movement.set_destination(position)

func select() -> void:
	sprite.modulate = color
	is_selected = true

func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

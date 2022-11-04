extends CharacterBody2D
class_name Unit

@export var color: Color
@export var speed: float = 1.0
var is_selected := false

@onready var sprite: Sprite2D = $Sprite2D
@onready var movement := $AgentMovement

func _physics_process(_delta):
	var velocity = movement.calc_velocity(global_position)
	move_and_collide(velocity)

func select() -> void:
	sprite.modulate = color
	is_selected = true
	
func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

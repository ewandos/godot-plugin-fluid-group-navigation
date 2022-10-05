extends CharacterBody2D
class_name Unit

@export var color: Color
var is_selected := false

@onready var sprite: Sprite2D = $Sprite2D

func select() -> void:
	sprite.modulate = color
	is_selected = true
	
func deselect() -> void:
	sprite.modulate = Color.WHITE
	is_selected = false

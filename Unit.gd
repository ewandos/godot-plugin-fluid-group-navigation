extends KinematicBody2D
class_name Unit

var is_selected := false

onready var sprite: Sprite = $Sprite

func _ready():
	sprite.material = sprite.material.duplicate()

func select() -> void:
	sprite.material.set('shader_param/line_thickness', 10.0)
	is_selected = true
	
func deselect() -> void:
	sprite.material.set('shader_param/line_thickness', 0.0)
	is_selected = false;

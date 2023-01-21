extends Node
class_name NavigationServer

@export var path_weight := 1.0
@export var separation_weight := 1.0
@export var cohesion_weight := 1.0

var agents: Array[NavigationAgent] = []

func _ready() -> void:
	agents = get_tree().get_nodes_in_group("agent")

func _calculate_velocity() -> void:
	pass

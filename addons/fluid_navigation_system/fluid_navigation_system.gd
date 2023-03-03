@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("FluidAgent", "Node2D", preload("AgentMovement.gd"), preload("icon.png"))


func _exit_tree() -> void:
	remove_custom_type("FluidAgent")

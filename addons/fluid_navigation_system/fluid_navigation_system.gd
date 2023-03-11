@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("FluidAgent", "Node2D", preload("fluid_agent_navigation.gd"), preload("agent_icon.png"))


func _exit_tree() -> void:
	remove_custom_type("FluidAgent")

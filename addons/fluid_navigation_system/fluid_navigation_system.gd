@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("FluidAgent", "Node2D", preload("scripts/fluid_agent_navigation.gd"), preload("icons/agent_icon.png"))
	add_custom_type("PathFollowForce", "Node2D", preload("scripts/forces/path_follow_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("AvoidanceForce", "Node2D", preload("scripts/forces/avoidance_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("SeparationForce", "Node2D", preload("scripts/forces/separation_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("CohesionForce", "Node2D", preload("scripts/forces/cohesion_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("AlignmentForce", "Node2D", preload("scripts/forces/alignment_force.gd"), preload("icons/force_icon.png"))

func _exit_tree() -> void:
	remove_custom_type("FluidAgent")
	remove_custom_type("PathFollowForce")
	remove_custom_type("AgentAvoidanceForce")
	remove_custom_type("SeparationForce")
	remove_custom_type("CohesionForce")
	remove_custom_type("AlignmentForce")

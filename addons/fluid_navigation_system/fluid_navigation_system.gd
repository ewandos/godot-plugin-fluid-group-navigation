@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_custom_type("FluidAgent", "Node2D", preload("scripts/fluid_agent_navigation.gd"), preload("icons/agent_icon.png"))
	add_custom_type("PathFollowForce", "FluidAgent", preload("scripts/forces/path_follow_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("AgentAvoidanceForce", "FluidAgent", preload("scripts/forces/agent_avoidance_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("SeparationForce", "FluidAgent", preload("scripts/forces/separation_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("CohesionForce", "FluidAgent", preload("scripts/forces/cohesion_force.gd"), preload("icons/force_icon.png"))
	add_custom_type("AlignmentForce", "FluidAgent", preload("scripts/forces/alignment_force.gd"), preload("icons/force_icon.png"))

func _exit_tree() -> void:
	remove_custom_type("FluidAgent")
	remove_custom_type("PathFollowForce")
	remove_custom_type("AgentAvoidanceForce")
	remove_custom_type("SeparationForce")
	remove_custom_type("CohesionForce")
	remove_custom_type("AlignmentForce")

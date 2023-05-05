extends Node2D
class_name UnitNavigationTest

@onready var unit: Unit = $Unit
@onready var target_position: Marker2D = $TargetPosition
@onready var breadcrumps: Line2D = $Breadcrumps
@onready var timer: Timer = $Timer

func start_test() -> void:
	unit.movement.set_destination(target_position.global_position)
	timer.start()

func _on_timer_timeout() -> void:
	breadcrumps.add_point(to_local(unit.global_position))

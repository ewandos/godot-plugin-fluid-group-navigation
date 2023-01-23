extends Node2D

var unit_navigation_tests: Array

func _ready() -> void:
	unit_navigation_tests = find_children("*", "UnitNavigationTest")

func _on_button_pressed() -> void:
	for unit_navigation_test in unit_navigation_tests:
		unit_navigation_test.start_test()

class_name FluidNavigationTest
extends Node2D

@onready var navigation_grid := $NavigationGrid2D as NavigationGrid2D

var completed_paths := 0
var agents := []

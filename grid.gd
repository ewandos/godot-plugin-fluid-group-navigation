class_name Grid
extends Resource

@export var size := Vector2(20, 20)
@export var cell_size := Vector2(64, 64)
@export var offset := cell_size / 2
@export var blocked_cells := PackedVector2Array()

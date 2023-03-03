extends Node
class_name HeadingSmoother

var sample_size = 15
var sample_history : Array[Vector2] = []
var next_empty_slot := 0

func _init(in_sample_size: int):
	sample_size = in_sample_size
	for i in range(0, sample_size):
		sample_history.append(Vector2.ZERO)

func update(value: Vector2):
	var combined_sum := Vector2.ZERO
	next_empty_slot += 1
	sample_history[next_empty_slot % sample_size] = value
	next_empty_slot %= sample_size

	for i in range(0, sample_history.size()):
		combined_sum += sample_history[i]

	return combined_sum / sample_history.size()


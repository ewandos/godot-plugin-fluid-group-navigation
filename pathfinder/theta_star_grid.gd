class_name ThetaStarGrid
extends AStarGrid2D

const DIRECTIONS = [
	Vector2(1, 0),   # Right
	Vector2(1, 1),   # Bottom Right
	Vector2(0, 1),   # Down
	Vector2(-1, 1),  # Bottom Left
	Vector2(-1, 0),  # Left
	Vector2(-1, -1), # Top Left
	Vector2(0, -1),  # Up
	Vector2(1, -1)   # Top Right
]


# Define a heuristic function (Euclidean distance) for A* algorithm
func heuristic(start_pos: Vector2, end_pos: Vector2) -> float:
	return start_pos.distance_to(end_pos)

# A* algorithm implementation
func calculate_path(start_pos: Vector2, end_pos: Vector2, use_theta := false) -> PackedVector2Array:
	var open_set := []  # Set of nodes to be evaluated
	var closed_set = []  # Set of nodes already evaluated
	var came_from = {}  # Dictionary to reconstruct the path
	var g_score = {}  # Cost from start along best known path
	var f_score = {}  # Estimated total cost from start to goal through y

	# Initialize dictionaries with default values for all grid cells
	for x in range(size.x):
		for y in range(size.y):
			var pos = Vector2(x, y)
			g_score[pos] = float('inf')
			f_score[pos] = float('inf')

	# Initialize starting position
	g_score[start_pos] = 0
	f_score[start_pos] = heuristic(start_pos, end_pos)
	came_from[start_pos] = start_pos
	open_set.append(start_pos)

	while open_set.size() != 0:
		# Find the node in open_set with the lowest f_score
		var current = open_set[0]
		var current_f_score = f_score[current]
		for pos in open_set:
			var pos_f_score = f_score[pos]
			if pos_f_score < current_f_score:
				current = pos
				current_f_score = pos_f_score

		# Check if the goal is reached
		if current == end_pos:
			return reconstruct_path(came_from, current)

		open_set.erase(current)
		closed_set.append(current)

		# Explore neighboring cells
		for direction in DIRECTIONS:
			var neighbor_pos = current + direction
			if neighbor_pos.x < 0 or neighbor_pos.y < 0 or neighbor_pos.x >= size.x or neighbor_pos.y >= size.y:
				continue  # Skip if the neighbor is outside the grid

			if is_point_solid(Vector2(neighbor_pos.x, neighbor_pos.y)):
				continue  # Skip if the neighbor is blocked

			if neighbor_pos in closed_set:
				continue  # Skip if the neighbor is already evaluated


			if use_theta and is_in_line_of_sight(came_from[current], neighbor_pos):
				var tentative_g_score = g_score[came_from[current]] + came_from[current].distance_to(neighbor_pos)

				if neighbor_pos not in open_set:
					open_set.append(neighbor_pos)
				elif tentative_g_score >= g_score[neighbor_pos]:
					continue  # Not a better path

				came_from[neighbor_pos] = came_from[current]
				g_score[neighbor_pos] = tentative_g_score
				f_score[neighbor_pos] = g_score[neighbor_pos] + heuristic(neighbor_pos, end_pos)

			else:
				# Calculate the tentative g_score based on the movement direction
				var tentative_g_score = g_score[current] + current.distance_to(neighbor_pos)

				if neighbor_pos not in open_set:
					open_set.append(neighbor_pos)
				elif tentative_g_score >= g_score[neighbor_pos]:
					continue  # Not a better path

				# This path is the best until now, record it
				came_from[neighbor_pos] = current
				g_score[neighbor_pos] = tentative_g_score
				f_score[neighbor_pos] = g_score[neighbor_pos] + heuristic(neighbor_pos, end_pos)

	# No path found
	return []

# Helper function to reconstruct the path from start to goal
func reconstruct_path(came_from: Dictionary, current: Vector2) -> PackedVector2Array:
	var total_path := [current * cell_size + cell_size / 2]
	while current in came_from:
		if current == came_from[current]: break
		current = came_from[current]
		total_path.insert(0, current * cell_size + cell_size / 2)
	return total_path


func is_in_line_of_sight(pos_1: Vector2, pos_2: Vector2) -> bool:
	var bresenham := Bresenham.new()

	var cells: PackedVector2Array = bresenham.get_cells_on_line(pos_1, pos_2)

	for cell in cells:
		if is_point_solid(cell): return false

	return true

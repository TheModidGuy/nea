extends Node2D

const INF: int = 1_000_000_000

func find_path(start_tile: Node, goal_tile: Node, unit) -> Array:
	if start_tile == null or goal_tile == null:
		return []

	var open_set := { start_tile: true }
	var came_from := {}

	var g_score := {}
	g_score[start_tile] = 0

	var f_score := {}
	f_score[start_tile] = heuristic(start_tile, goal_tile)

	while open_set.size() > 0:
		var current := lowest_f(open_set, f_score)
		if current == goal_tile:
			return reconstruct(came_from, current)

		open_set.erase(current)

		for neighbor in current.neighbors:
			var cost: int = unit.get_tile_cost(neighbor)
			if cost >= INF:
				continue

			var tentative: int = int(g_score[current]) + cost
			if tentative < g_score.get(neighbor, INF):
				came_from[neighbor] = current
				g_score[neighbor] = tentative
				f_score[neighbor] = tentative + heuristic(neighbor, goal_tile)
				open_set[neighbor] = true

	return []

func heuristic(a: Node, b: Node) -> int:
	return abs(a.grid_x - b.grid_x) + abs(a.grid_y - b.grid_y)

func lowest_f(open_set: Dictionary, f_score: Dictionary) -> Node:
	var best: Node = null
	var best_f := INF
	for node in open_set.keys():
		var f := int(f_score.get(node, INF))
		if f < best_f:
			best_f = f
			best = node
	return best

func reconstruct(came_from: Dictionary, current: Node) -> Array:
	var path := [current]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path

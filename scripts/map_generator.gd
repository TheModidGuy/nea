extends Node2D

var overlay: Node = null

const INF: int = 1_000_000_000

var player_instance: Node = null

@export var hex_tile_scene: PackedScene
@export var player: PackedScene
@export var enemy_scene: PackedScene
@export var map_width: int = 25
@export var map_height: int = 25
@export var tile_size: float = 64.0
@export var count: int = 0

# Noise objects
var terrain_noise := FastNoiseLite.new()
var tiles: Array = []

var highlight_sprite: Sprite2D = null
var last_highlighted_tile: Node = null

var enemies: Array = []

func _ready():
	randomize()
	terrain_noise.seed = randi()
	terrain_noise.frequency = 0.1
	
	await get_tree().process_frame

	var overlays = get_tree().get_nodes_in_group("OverlayUI")
	if overlays.size() > 0:
		overlay = overlays[0]
		overlay.map = self
	else:
		push_warning("Overlay not found")
	
	
	
	generate_map()
	connect_neighbors()
	place_player(4,4)
	
	game_spawn_enemy(count)
	
	
	player_instance.connect("moved",Callable(self, "enemy_turn"))

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var clicked_tile = get_tile_from_mouse(mouse_pos)
		if clicked_tile:
			highlight_tile(clicked_tile)#
			if overlay:
				overlay.update_tile_info(clicked_tile)


func generate_map():
	tiles.clear()
	
	for y in range(map_height):
		tiles.append([])
		for x in range(map_width):
			var tile_instance = hex_tile_scene.instantiate()
			
			# Hex grid positioning
			tile_instance.position = Vector2(x * tile_size, y * tile_size)
			
			# Terrain from noise
			var n = terrain_noise.get_noise_2d(x, y)
			n = (n + 1) / 2  # normalize to 0–1

			if n < 0.3:
				tile_instance.terrainType = "water"
			elif n < 0.6:
				tile_instance.terrainType = "grass"
			else:
				tile_instance.terrainType = "snow"
			
			tile_instance.grid_x = x
			tile_instance.grid_y = y
			tile_instance.neighbors.clear()
				
			add_child(tile_instance)
			tiles[y].append(tile_instance)

			## Optional: resource placement
			#var r = resource_noise.get_noise_2d(x, y)
			#r = (r + 1) / 2
			#tile_instance.has_resource = (r > 0.7 and tile_instance.terrainType != "water")

func connect_neighbors():
	var directions = [
		Vector2(1,0),
		Vector2(-1,0),
		Vector2(0,1),
		Vector2(0,-1)
	]
	
	for y in range(map_height):
		for x in range(map_width):
			var t = tiles[y][x]
			t.neighbors.clear()
			
			for d in directions:
				var nx = x + int(d.x)
				var ny = y + int(d.y)
				if nx >= 0 and nx < map_width and ny >= 0 and ny < map_height:
					t.neighbors.append(tiles[ny][nx])
	
	print("Tile (0,0) neighbors: ", tiles[0][0].neighbors.size())
	print("Tile (1,0) neighbors: ", tiles[1][0].neighbors.size())
	print("Tile (7,7) neighbors: ", tiles[7][7].neighbors.size())
	print("Tile (25,25) neighbors: ", tiles[24][24].neighbors.size())

func get_tile(x: int, y: int) -> Node:
	if y >= 0 and y < map_height and x >= 0 and x < map_width:
		return tiles[y][x]
	return null
	
func place_player(x: int = 0, y: int = 0):
	if player == null:
		push_error("Player scene not found")
		return
	
	var tile = get_tile(x,y)
	if tile == null:
		push_error("Tile not found")
		return
	
	player_instance = player.instantiate()
	add_child(player_instance)
	
	player_instance.position = tile.position
	player_instance.z_index = 10
	
	player_instance.currentTile = tile
	print("Player spawned at x: {x} y: {y}".format({
	"x": player_instance.currentTile.grid_x,
	"y": player_instance.currentTile.grid_y
}))

func spawn_enemy(x: int, y: int):
	var tile = get_tile(x,y)
	if tile == null:
		push_error("Spawn tile not found")
		return
	var e = enemy_scene.instantiate()
	add_child(e)
	
	e.position = tile.position
	e.currentTile = tile
	
	enemies.append(e)
	return e

# This is for spawning multiple enemies
func game_spawn_enemy(count):
	if count == 0:
		return
	else:
		for e in count:
			var enemy_spawn_x = randi_range(0,24)
			var enemy_spawn_y = randi_range(0,24)
			spawn_enemy(enemy_spawn_x,enemy_spawn_y)

func get_tile_from_mouse(mouse_pos: Vector2) -> Node:
	for y in range(map_height):
		for x in range(map_width):
			var tile = tiles[y][x]
			var tile_pos = tile.position
			var half_size = tile_size / 2
			if abs(mouse_pos.x - tile_pos.x) < half_size and abs(mouse_pos.y - tile_pos.y) < half_size:
				return tile
	return null


func highlight_tile(tile: Node):
	if last_highlighted_tile == tile:
		return

	if highlight_sprite:
		highlight_sprite.queue_free()

	highlight_sprite = Sprite2D.new()
	highlight_sprite.texture = load("res://Assets/Sprites/Tiles/tileHighlight.png")
	highlight_sprite.position = tile.position
	add_child(highlight_sprite)

	last_highlighted_tile = tile


func move_player_to(tile):
	if player_instance == null:
		push_warning("Player not found")
		return
	
	if player_instance.moveToTile(tile):
		enemy_turn()

func enemy_turn():
	if player_instance == null:
		return
	
	var goal_tile = player_instance.currentTile
	if goal_tile == null:
		push_error("Player location lost")
		return
	
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.currentTile == null:
			continue
		
		var start_tile = enemy.currentTile
		var path = A_star(start_tile, goal_tile)
		
		if path.size() > 1:
			var next_tile = path[1]
			enemy.position = next_tile.position
			enemy.currentTile = next_tile

# -----------------------------------------------------
# THIS IS ALL FOR THE A* ALGORITHM
# -----------------------------------------------------

# I am so shocked this works. Lord Jesus Christ, please make sure this code does not randomly break

func heuristic(a: Node, b: Node) -> int:
	# Manhattan
	return abs(a.grid_x - b.grid_x) + abs(a.grid_y - b.grid_y)

func _lowest_f(open_set: Dictionary, f_score: Dictionary) -> Node:
	var best: Node = null
	var best_f: int = INF
	for node in open_set.keys():
		var f = int(f_score.get(node, INF))
		if f < best_f:
			best_f = f
			best = node
	return best

func _reconstruct(came_from: Dictionary, current: Node) -> Array:
	var path: Array = [current]
	while came_from.has(current):
		current = came_from[current]
		path.push_front(current)
	return path

func A_star(start_tile: Node, goal_tile: Node) -> Array:
	var open_set: Dictionary = {start_tile: true}
	var came_from: Dictionary = {}
	var g_score: Dictionary = {}
	g_score[start_tile] = 0
	var f_score: Dictionary = {}
	f_score[start_tile] = int(heuristic(start_tile, goal_tile))
	
	while open_set.size() > 0:
		var current: Node = _lowest_f(open_set, f_score)
		if current == goal_tile:
			return _reconstruct(came_from, current)
		
		open_set.erase(current)
		
		for neighbor in current.neighbors:
			if int(neighbor.cost) >= INF:
				continue
			
			var current_g: int = int(g_score.get(current, INF))
			var tentative_g: int = current_g + int(neighbor.cost)
			var neighbor_g: int = int(g_score.get(neighbor, INF))
			
			if tentative_g < neighbor_g:
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g
				f_score[neighbor] = tentative_g + int(heuristic(neighbor, goal_tile))
				open_set[neighbor] = true
				
	return []

# -----------------------------------------------------
# THIS IS THE END FOR THE A* ALGORITHM
# -----------------------------------------------------

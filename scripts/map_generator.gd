extends Node2D

@export var hex_tile_scene: PackedScene
@export var map_width: int = 25
@export var map_height: int = 25
@export var tile_size: float = 64.0

# Noise objects
var terrain_noise := FastNoiseLite.new()
var tiles: Array = []

func _ready():
	randomize()
	terrain_noise.seed = randi()
	terrain_noise.frequency = 0.1

	generate_map()
	connect_neighbors()

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
			
			if "grid_x" in tile_instance:
				tile_instance.grid_x = x
			if "grid_y" in tile_instance:
				tile_instance.grid_y = y
			if "neighbors" in tile_instance:
				tile_instance.neighbors = []
				
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
			
func get_tile(x: int, y: int) -> Node:
	if y >= 0 and y < map_height and x >= 0 and x < map_width:
		return tiles[y][x]
	return null

extends Node2D

@export var hex_tile_scene: PackedScene
@export var map_width: int = 25
@export var map_height: int = 25
@export var hex_width: float = 64
@export var hex_height: float = 48

var tiles = []

# Noise objects
var terrain_noise := FastNoiseLite.new()

func _ready():
	randomize()
	# Configure terrain noise (default type)
	terrain_noise.seed = randi()
	terrain_noise.frequency = 0.1

	generate_map()

func generate_map():
	for y in range(map_height):
		for x in range(map_width):
			var tile_instance = hex_tile_scene.instantiate()
			
			# Hex grid positioning (pointy-top)
			var offset_x = hex_width * x
			var offset_y = hex_height * y
			if y % 2 != 0:
				offset_x += hex_width / 2
			tile_instance.position = Vector2(offset_x, offset_y)

			# Terrain from noise
			var n = terrain_noise.get_noise_2d(x, y)
			n = (n + 1) / 2  # normalize to 0–1

			if n < 0.4:
				tile_instance.terrainType = "water"
			elif n < 0.4:
				tile_instance.terrainType = "grass"
			elif n < 0.2:
				tile_instance.terrainType = "snow"

			## Optional: resource placement
			#var r = resource_noise.get_noise_2d(x, y)
			#r = (r + 1) / 2
			#tile_instance.has_resource = (r > 0.7 and tile_instance.terrainType != "water")

			add_child(tile_instance)

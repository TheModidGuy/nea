extends Node2D

var overlay: Node = null

var player_instance: Node = null

@export var hex_tile_scene: PackedScene
@export var player: PackedScene
@export var map_width: int = 25
@export var map_height: int = 25
@export var tile_size: float = 64.0

# Noise objects
var terrain_noise := FastNoiseLite.new()
var tiles: Array = []

var highlight_sprite: Sprite2D = null
var last_highlighted_tile: Node = null

func _ready():
	randomize()
	terrain_noise.seed = randi()
	terrain_noise.frequency = 0.1
	
	var overlays = get_tree().get_nodes_in_group("OverlayUI")
	if overlays.size() > 0:
		overlay = overlays[0]
	else:
		push_warning("Overlay not found")
	
	generate_map()
	connect_neighbors()
	place_player(5,4)

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
	
	player_instance.moveToTile(tile)

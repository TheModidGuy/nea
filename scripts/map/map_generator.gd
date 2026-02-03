extends Node2D

var overlay: Node = null

const INF: int = 1000000000
const PLAYER_SAFE_RADIUS := 10
const ENEMY_SAFE_RADIUS := 5
const ENEMY_AGGRO_RADIUS := 4

var player_instance: Node = null

@export var astar_scene: PackedScene
var astar: Node2D

@export var hex_tile_scene: PackedScene
@export var player: PackedScene
@export var enemy_spawner_scene: PackedScene
var enemy_spawner

@export var map_width: int = 25
@export var map_height: int = 25
@export var tile_size: float = 64.0
@export var count: int = 0

@export var building_scene: PackedScene
@export var building_count = 0
var occupied_tiles := []

# Noise objects
var terrain_noise := FastNoiseLite.new()
var tiles: Array = []

var highlight_sprite: Sprite2D = null
var last_highlighted_tile: Node = null


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
	
	overlay.move_requested.connect(request_player_move)
	
	if astar_scene == null:
		push_error("AStarScene not assigned")
		return

	astar = astar_scene.instantiate()
	add_child(astar)

	
	if enemy_spawner_scene == null:
		push_error("Can't find enemy spawner scene")
		return
	else:
		enemy_spawner = enemy_spawner_scene.instantiate()
		add_child(enemy_spawner)
		enemy_spawner.setup(self)
	
	generate_map()
	connect_neighbors()
	place_player(4,4)
	spawn_buildings()
	spawn_initial_enemies()
	
	spawn_boss_building()
	
	
	player_instance.connect("moved",Callable(self, "enemy_turn"))

func _unhandled_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var mouse_pos = get_global_mouse_position()
		var clicked_tile = get_tile_from_mouse(mouse_pos)
		if clicked_tile:
			highlight_tile(clicked_tile)
			if overlay:
				overlay.update_tile_info(clicked_tile)
	if event.is_action_pressed("player_move"):
		request_player_move()

func request_player_move():
	var tile_to_move = last_highlighted_tile
	if tile_to_move == null:
		return
		
	move_player_to(tile_to_move)

func tile_can_have_building(tile) -> bool:
	if tile.terrainType == "water":
		return false
	if tile in occupied_tiles:
		return false
	if player_instance != null and tile == player_instance.currentTile:
		return false
	return true

func get_random_free_tile():
	var attempts := 0

	while attempts < 100:
		attempts += 1
		var x := randi_range(0, map_width - 1)
		var y := randi_range(0, map_height - 1)
		var tile := get_tile(x, y)

		if tile and tile_can_have_building(tile):
			return tile

	return null

func spawn_building(tile, forced_type := ""):
	var building = building_scene.instantiate()

	if forced_type != "":
		building.building_type = forced_type
	else:
		building.building_type = building.pick_building_type()
	
	if overlay and building.building_type == "shop":
		building.shop_entered.connect(overlay.show_shop)

	building.name = "Building"
	building.currentTile = tile

	tile.has_building = true
	tile.building_on_tile = building.building_type

	tile.add_child(building)
	building.position = Vector2.ZERO

	occupied_tiles.append(tile)

func spawn_boss_building():
	var x := map_width - 4
	var y := map_height - 4

	var tile := get_tile(x, y)
	if tile == null:
		push_error("Boss tile out of bounds")
		return

	spawn_building(tile, "boss")


func spawn_buildings():
	if building_count < 5:
		push_error("building_count must be at least 5")
		return
	
	var required := ["city", "shop", "dungeon", "tower", "castle"]

	# Guarantee at least one of each
	for type in required:
		var tile = get_random_free_tile()
		if tile:
			spawn_building(tile, type)

	# Spawn the rest randomly
	var remaining: int = building_count - required.size()
	for i in range(remaining):
		var tile = get_random_free_tile()
		if tile:
			spawn_building(tile)


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
				tile_instance.terrainType = "mountain"
			elif n < 0.4:
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
	
	player_instance.currentTile = tile
	player_instance.position = tile.position
	player_instance.z_index = 10
	
	player_instance.currentTile = tile
	print("Player spawned at x: {x} y: {y}".format({
	"x": player_instance.currentTile.grid_x,
	"y": player_instance.currentTile.grid_y
	}))
	
	if overlay:
		overlay.bind_player(player_instance)
		overlay.player = player_instance
		overlay.bind_inventory(player_instance.inventory)
		player_instance.moved.connect(overlay._on_player_moved)
	
	#inventory test
	var potion: Item = load("res://scripts/Inventory and Item/items/consumable items/medium_health_potion.tres")
	var sword: Item = load("res://scripts/Inventory and Item/items/weapon items/stone_sword.tres")
	
	player_instance.inventory.add_item(potion, 3)
	player_instance.inventory.add_item(sword, 1)

func spawn_initial_enemies():
	var attempts := 0
	var spawned := 0
	var max_attempts := count * 10

	while spawned < count and attempts < max_attempts:
		attempts += 1

		var x = randi_range(0, map_width - 1)
		var y = randi_range(0, map_height - 1)
		var tile = get_tile(x, y)

		if tile == null:
			continue

		if tile.terrainType == "water":
			continue

		# Too close to player
		if player_instance != null:
			if tile_distance(tile, player_instance.currentTile) < PLAYER_SAFE_RADIUS:
				continue

		# Too close to other enemies
		var too_close := false
		for enemy in enemy_spawner.enemies:
			if enemy.currentTile == null:
				continue
			if tile_distance(tile, enemy.currentTile) < ENEMY_SAFE_RADIUS:
				too_close = true
				break

		if too_close:
			continue

		enemy_spawner.spawn_enemy_on_tile(tile)
		spawned += 1



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
		
	if BattleState.enemies_paused:
		return
	
	if BattleState.run_escape_tile != null:
		var dist_from_escape = tile_distance(
			player_instance.currentTile,
			BattleState.run_escape_tile
		)

		if dist_from_escape < BattleState.run_escape_radius:
			return
		else:
			# Player moved past distance
			BattleState.run_escape_tile = null

	
	var player_tile = player_instance.currentTile
	if player_tile == null:
		return
	
	for enemy in enemy_spawner.enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.currentTile == null:
			continue
		
		# Skip enemies outside aggro range
		var dist := tile_distance(enemy.currentTile, player_instance.currentTile)
		if dist > ENEMY_AGGRO_RADIUS:
			continue
		
		# Move towards player
		var path = astar.find_path(enemy.currentTile, player_instance.currentTile, enemy)
		if path.size() > 1:
			var next_tile = path[1]
			enemy.position = next_tile.position
			enemy.currentTile = next_tile
		
		# Trigger battle if enemy ends up on the same tile as player
		if enemy.currentTile == player_instance.currentTile:
			enemy.try_start_battle(player_instance)



func tile_distance(a: Node, b: Node) -> int:
	return abs(a.grid_x - b.grid_x) + abs(a.grid_y - b.grid_y)









# saving stuff !!!!!!!!!!!!!!!!!!

func encode_terrain(t: String) -> String:
	match t:
		"grass": return "g"
		"water": return "w"
		"mountain": return "m"
		"snow": return "s"
	return "g"

func decode_terrain(c: String) -> String:
	match c:
		"g": return "grass"
		"w": return "water"
		"m": return "mountain"
		"s": return "snow"
	return "grass"

func serialize_map() -> Dictionary:
	var data := {}
	data.w = map_width
	data.h = map_height

	# Tiles
	var tile_data := []
	for y in range(map_height):
		for x in range(map_width):
			var tile = tiles[y][x]
			tile_data.append(encode_terrain(tile.terrainType))
	data.tiles = tile_data

	# Buildings 
	var building_data := []
	for y in range(map_height):
		for x in range(map_width):
			var tile = tiles[y][x]
			if tile.has_building:
				building_data.append({
					"x": x,
					"y": y,
					"t": tile.building_on_tile
				})
	data.buildings = building_data

	# Enemies
	var enemy_data := []
	for enemy in enemy_spawner.enemies:
		if not is_instance_valid(enemy):
			continue
		enemy_data.append({
			"x": enemy.currentTile.grid_x,
			"y": enemy.currentTile.grid_y,
			"t": enemy.name
		})
	data.enemies = enemy_data

	return data

func load_map_from_data(data: Dictionary):
	map_width = data.w
	map_height = data.h

	# Clear old map
	for row in tiles:
		for tile in row:
			tile.queue_free()
	tiles.clear()

	# Create tiles
	var i := 0
	for y in range(map_height):
		tiles.append([])
		for x in range(map_width):
			var tile = hex_tile_scene.instantiate()
			tile.position = Vector2(x * tile_size, y * tile_size)
			tile.grid_x = x
			tile.grid_y = y
			tile.terrainType = decode_terrain(data.tiles[i])
			i += 1

			add_child(tile)
			tiles[y].append(tile)

	connect_neighbors()

	# Buildings
	for b in data.buildings:
		var tile = get_tile(b.x, b.y)
		spawn_building(tile, b.t)

	# Enemies
	for e in data.enemies:
		var tile = get_tile(e.x, e.y)
		match e.t:
			"wolf": enemy_spawner.spawn_specific_enemy_on_tile(enemy_spawner.wolf_scene, tile)
			"bandit": enemy_spawner.spawn_specific_enemy_on_tile(enemy_spawner.bandit_scene, tile)
			"dragon": enemy_spawner.spawn_specific_enemy_on_tile(enemy_spawner.dragon_scene, tile)


func generate_save_string() -> String:
	var dict = serialize_map()
	var json := JSON.stringify(dict)
	var bytes: PackedByteArray = json.to_utf8_buffer()
	return Marshalls.raw_to_base64(bytes)


func parse_save_string(save_string: String) -> Dictionary:
	var bytes: PackedByteArray = Marshalls.base64_to_raw(save_string)
	var json_string := bytes.get_string_from_utf8()
	var result = JSON.parse_string(json_string)

	if typeof(result) != TYPE_DICTIONARY:
		push_error("Invalid save string")
		return {}

	return result

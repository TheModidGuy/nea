extends Node

@export var wolf_scene: PackedScene
@export var bandit_scene: PackedScene
@export var dragon_scene: PackedScene

@export var wizard_scene: PackedScene

var enemies: Array = []
var map

const ENEMIES = [
	{"scene": "wolf", "weight": 50},
	{"scene": "bandit", "weight": 35},
	{"scene": "dragon", "weight": 5}
]

func setup(map_ref):
	map = map_ref

func spawn_specific_enemy_on_tile(enemy_scene: PackedScene, tile):
	var enemy = enemy_scene.instantiate()
	enemy.position = tile.position
	enemy.currentTile = tile
	map.add_child(enemy)
	enemies.append(enemy)

#spawns an enemy on a tile
func spawn_enemy_on_tile(tile):
	var enemy = _pick_enemy().instantiate()
	enemy.position = tile.position
	enemy.currentTile = tile
	map.add_child(enemy)
	enemies.append(enemy)

# randomly choses an enemy
func _pick_enemy() -> PackedScene:
	var total := 0
	for e in ENEMIES:
		total += e.weight
	
	var roll = randi() % total
	var current := 0
	
	for e in ENEMIES:
		current += e.weight
		if roll < current:
			match e.scene:
				"wolf": return wolf_scene
				"bandit": return bandit_scene
				"dragon": return dragon_scene
	
	return wolf_scene

# returns any enemty on tile
func get_enemies_on_tile(tile):
	var result := []
	for enemy in enemies:
		if not is_instance_valid(enemy):
			continue
		if enemy.currentTile == tile:
			result.append(enemy)
	return result

func remove_enemy(enemy):
	enemies.erase(enemy)

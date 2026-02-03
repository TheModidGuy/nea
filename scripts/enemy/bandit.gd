extends Enemy
class_name Bandit



func _ready():
	enemy_type = "bandit"

	#Stats for bandit
	health_min= 25
	health_max = 75

	speed_min = 5
	speed_max = 15

	attack_min = 5
	attack_max = 20

	defence_min = 5
	defence_max = 10

	crit_min = 0
	crit_max = 3

	crit_chance_min = 5
	crit_chance_max = 20
	
	gold_min = 20
	gold_max = 50
	
	super._ready()

#bandit specific movement calculation
func get_tile_cost(tile: Node) -> int:
	if tile.terrainType == "snow":
		return 10
	else:
		return tile.cost

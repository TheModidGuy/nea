extends Enemy
class_name Bandit

func _ready():
	health_min= 25
	health_max = 75

	speed_min = 5
	speed_max = 15

	attack_min = 5
	attack_max = 20

	defence_min = 5
	defence_max = 10

	magic_skill_min = 0
	magic_skill_max = 5

	crit_min = 0
	crit_max = 3

	crit_chance_min = 5
	crit_chance_max = 20
	
	super._ready()

func get_tile_cost(tile: Node) -> int:
	if tile.terrainType == "snow":
		return 10
	else:
		return tile.cost

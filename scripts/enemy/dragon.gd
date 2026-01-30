extends Enemy
class_name Dragon

func _ready():
	#stats for dragon
	health_min= 30
	health_max = 60

	speed_min = 5
	speed_max = 10

	attack_min = 20
	attack_max = 30

	defence_min = 5
	defence_max = 10

	magic_skill_min = 2
	magic_skill_max = 6

	crit_min = 1
	crit_max = 2

	crit_chance_min = 0
	crit_chance_max = 20
	
	super._ready()

#dragon specific movement calculation
func get_tile_cost(tile: Node) -> int:
	if tile.terrainType == "moutain":
		return 1000000
	else:
		return tile.cost

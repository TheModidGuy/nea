extends Enemy
class_name Wolf

func _ready():
	#stats for wolf
	health_min= 10
	health_max = 50

	speed_min = 10
	speed_max = 25

	attack_min = 5
	attack_max = 10

	defence_min = 1
	defence_max = 5

	crit_min = 0
	crit_max = 2

	crit_chance_min = 0
	crit_chance_max = 10
	
	gold_min = 50
	gold_max = 100
	
	super._ready()

#tile cost specific for wolf
func get_tile_cost(tile: Node) -> int:
	if tile.terrainType == "grass" || tile.terrainType == "snow":
		return 1
	else:
		return 1000000

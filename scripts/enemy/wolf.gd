extends Enemy
class_name Wolf

func _ready():
	health_min= 10
	health_max = 50

	speed_min = 10
	speed_max = 25

	attack_min = 5
	attack_max = 10

	defence_min = 1
	defence_max = 5

	magic_skill_min = 0
	magic_skill_max = 0

	crit_min = 0
	crit_max = 2

	crit_chance_min = 0
	crit_chance_max = 10

func get_tile_cost(tile: Node) -> int:
	

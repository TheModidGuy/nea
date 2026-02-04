extends Enemy
class_name Wizard

func _ready():
	#stats for wizard
	health_min= 500
	health_max = 800

	speed_min = 20
	speed_max = 40

	attack_min = 50
	attack_max = 80

	defence_min = 20
	defence_max = 45

	gold_min = 1
	gold_max = 2
	
	super._ready()

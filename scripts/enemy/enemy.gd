extends Node2D
class_name Enemy

var currentTile: Node = null

# stats :P
var health: int 
var speed: int
var attack: int
var defence: int
var magic_skill: int
var crit: int
var crit_chance: int

var health_min: int = 10
var health_max: int = 500

var speed_min: int = 0
var speed_max: int = 100

var attack_min: int = 1
var attack_max: int = 100

var defence_min: int = 0
var defence_max: int = 100

var magic_skill_min: int = 0
var magic_skill_max: int = 100

var crit_min: int = 0
var crit_max: int = 5

var crit_chance_min: int = 0
var crit_chance_max: int = 100

func _ready():
	randomize_stats()

func randomize_stats():
	health = randi_range(health_min, health_max)
	speed = randi_range(speed_min, speed_max)
	attack = randi_range(attack_min, attack_max)
	defence = randi_range(defence_min, defence_max)
	magic_skill = randi_range(magic_skill_min, magic_skill_max)
	crit = randi_range(crit_min, crit_max)
	crit_chance = randi_range(crit_chance_min, crit_chance_max)

func get_tile_cost(tile) -> int:
	if tile.has_building:
		return INF
	return tile.cost

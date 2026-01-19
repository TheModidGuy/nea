extends Node2D

@onready var inventory: Inventory = $Inventory

var currentTile: Node = null
var energy: int = 50
var health: int = 25
var outOfEnergy: bool = false

var speed: int = 6
var attack: int = 7
var defence: int = 6
var magic_skill: int = 5
var crit: int = 2

var gold: int = 0

var crit_chance: int = 5

signal moved(new_tile)

func moveToTile(tile) -> bool:
	if currentTile == tile:
		return false
	if tile not in currentTile.neighbors:
		print("Tile not adjacent")
		return false
		
	var cost = tile.cost
	
	if energy < cost or energy - cost < 0:
		energy = 0
		print("Not enough energy")
		outOfEnergy = true
		if health > 20:
			health -= 1
		print("Health: ", health)
		
	position = tile.position
	currentTile = tile
	if !outOfEnergy:
		energy -= cost
	print("Moved to: ", tile.terrainType, "Energy left: ", energy)

	emit_signal("moved", tile)
	return true

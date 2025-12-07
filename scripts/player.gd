extends Node2D

# this code is so shit see if I can make it better later

var currentTile: Node = null
var energy: int = 50
var health: int = 25
var outOfEnergy: bool = false

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

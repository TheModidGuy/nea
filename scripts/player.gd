extends Node2D

var currentTile: Node = null
var energy: int = 100

func moveToTile(tile):
	if currentTile == tile:
		return
	var cost = tile.cost
	if energy < cost:
		print("Not enough energy")
		return
	position = tile.position
	currentTile = tile
	energy -= cost
	print("Moved to: ", tile.terrainType, "Energy left: ", energy)

extends Node2D
class_name Player

signal battle_started(player)

@onready var inventory: Inventory = $Inventory

var currentTile: Node = null
var energy: int = 50
var health: int = 100
var max_health: int = 100
var outOfEnergy: bool = false

var speed: int = 6
var attack: int = 7
var defence: int = 6
var magic_skill: int = 5
var crit: int = 2

var gold: int = 100

var crit_chance: int = 5

enum BattlePhase {
	PLAYER_TURN,
	ENEMY_TURN
}

var battle_phase: BattlePhase = BattlePhase.PLAYER_TURN

#battle stuff
var battle_locked: bool = false
var current_enemy: Enemy = null
var in_battle: bool = false


signal moved(new_tile)

func moveToTile(tile) -> bool:
	if currentTile == tile:
		return false
	if tile not in currentTile.neighbors:
		print("Tile not adjacent")
		return false
	if in_battle or battle_locked:
		print("Canot move: in battle")
		return false
	
	var cost = tile.cost
	
	if energy < cost or energy - cost < 0:
		energy = 0
		print("Not enough energy")
		outOfEnergy = true
		if health > 20:
			health -= 1
		print("Health: ", health)
		
	# movement
	position = tile.position
	currentTile = tile
	
	if !outOfEnergy:
		energy -= cost
		
	print("Moved to: ", tile.terrainType, "Energy left: ", energy)
	
	#building stuff
	if tile.has_building:
		var building = tile.get_node_or_null("Building")
		if building:
			building.interact(self)
	
	# battle stuff
	var enemies_here = tile.get_enemies_on_tile()
	if enemies_here.size() > 0:
		for enemy in enemies_here:
			enemy.try_start_battle(self)
			break  # only start with the first enemy
	
	emit_signal("moved", tile)
	
	print("Player moved to:", tile.grid_x, tile.grid_y, "Enemies here:", enemies_here.size())
	print("Battle locked:", battle_locked, "In battle:", in_battle)
	
	return true

func use_item_from_inventory(index: int):
	var slot = inventory.slots[index]
	if slot == null:
		return

	var item: Item = slot["item"]

	# --- CONSUMABLE ---
	if item is ConsumableItem:
		var c := item as ConsumableItem

		if c.heal_amount > 0:
			health += c.heal_amount

		if c.energy_amount > 0:
			energy += c.energy_amount

		health = min(health, 100)
		energy = min(energy, 50)

		inventory.remove_item(index, 1)
		return


	# --- WEAPON ---
	if item is WeaponItem:
		var w := item as WeaponItem
		attack += w.attack_bonus
		crit += w.crit_bonus

		inventory.remove_item(index, 1)
		return


	# --- ARMOUR ---
	if item is ArmourItem:
		var a := item as ArmourItem
		defence += a.defence_bonus

		inventory.remove_item(index, 1)
		return

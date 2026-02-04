extends Node2D
class_name Player

signal battle_started
signal battle_ended(player_won)

@onready var inventory: Inventory = $Inventory

const ENEMY_SAFE_RADIUS := 5

var currentTile: Node = null
var energy: int = 100
var max_energy: int = 100
var health: int = 100
var max_health: int = 100

var speed: int = 6
var attack: int = 7
var defence: int = 6
var magic_skill: int = 100
var crit: int = 2

var gold: int = 100
var gold_earned := 0
var gold_spent := 0

var crit_chance: int = 5

var net_gold:
	get:
		return gold_earned - gold_spent

var total_kills: int = 0
var tiles_moved: int = 0

enum BattlePhase {
	PLAYER_TURN,
	ENEMY_TURN,
	BATTLE_OVER
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
	
	if energy >= cost:
		energy -= cost
	else:
		energy = 0
		if health > 20:
			health -= 1
		
	# movement
	position = tile.position
	currentTile = tile
	
	tiles_moved += 1
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
			break
	
	emit_signal("moved", tile)
	
	print("Player moved to:", tile.grid_x, tile.grid_y, "Enemies here:", enemies_here.size())
	print("Battle locked:", battle_locked, "In battle:", in_battle)
	
	return true

func use_item_from_inventory(index: int):
	var slot = inventory.slots[index]
	if slot == null:
		return

	var item: Item = slot["item"]

	# consumable stuff
	if item is ConsumableItem:
		var c := item as ConsumableItem

		if c.heal_amount > 0:
			health += c.heal_amount

		if c.energy_amount > 0:
			energy += c.energy_amount

		if c.mana_amount > 0:
			magic_skill += c.mana_amount

		health = min(health, max_health)
		energy = min(energy, max_energy)
		magic_skill = min(magic_skill, 100)

		inventory.remove_item(index, 1)
		return


	# weapon stuff
	if item is WeaponItem:
		var w := item as WeaponItem
		attack += w.attack_bonus
		crit += w.crit_bonus

		inventory.remove_item(index, 1)
		return


	# armour stuff
	if item is ArmourItem:
		var a := item as ArmourItem
		defence += a.defence_bonus

		inventory.remove_item(index, 1)
		return



# battle controls
func end_battle(player_won: bool):
	if not player_won and health <= 0:
		game_over()
		return
	
	print("Battle ended. Player won:", player_won)
	BattleState.enemies_paused = false
	battle_phase = BattlePhase.BATTLE_OVER
	in_battle = false
	battle_locked = false
	battle_ended.emit(player_won)
	
	BattleState.run_escape_tile = currentTile
	BattleState.run_escape_radius = ENEMY_SAFE_RADIUS
	


func attack_enemy():
	if not in_battle or battle_phase != BattlePhase.PLAYER_TURN:
		return
	if current_enemy == null:
		return

	var damage = max(1, attack - current_enemy.defence)
	current_enemy.health -= damage
	
	print("Player hits enemy for", damage)
	
	if current_enemy.health <= 0:
		current_enemy.health = 0
		var enemy = current_enemy
		end_battle(true)
		enemy.die(self)
	else:
		battle_phase = BattlePhase.ENEMY_TURN

func cast_magic():
	if not in_battle or battle_phase != BattlePhase.PLAYER_TURN:
		return
	if current_enemy == null:
		return
		
	if magic_skill < 25:
		print("Not enough magic")
		return
	
	magic_skill -= 25
	
	var damage = attack * 2 + 10
	current_enemy.health -= damage

	print("Player casts magic for", damage)

	if current_enemy.health <= 0:
		current_enemy.health = 0
		var enemy = current_enemy
		end_battle(true)
		enemy.die(self)
	else:
		battle_phase = BattlePhase.ENEMY_TURN

func try_run():
	if not in_battle or current_enemy == null:
		return false

	if speed > current_enemy.speed:
		BattleState.run_escape_tile = currentTile
		end_battle(false)
		return true

	var speed_diff = current_enemy.speed - speed
	var fail_chance = min(0.8, speed_diff * 0.15)

	if randf() > fail_chance:
		BattleState.run_escape_tile = currentTile
		end_battle(false)
		return true

	print("Failed to run")
	battle_phase = BattlePhase.ENEMY_TURN
	return false

func game_over():
	get_tree().change_scene_to_file("res://Scene/Map/Main Menu.tscn")

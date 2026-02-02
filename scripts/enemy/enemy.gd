extends Node2D
class_name Enemy

var currentTile: Node = null

# stats :P
var health: int
var max_health: int
var speed: int
var attack: int
var defence: int
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

var crit_min: int = 0
var crit_max: int = 5

var crit_chance_min: int = 0
var crit_chance_max: int = 100

var gold_min := 0
var gold_max := 0

func _ready():
	randomise_stats()

#randomises stats 
func randomise_stats():
	max_health = randi_range(health_min, health_max)
	health = max_health

	speed = randi_range(speed_min, speed_max)
	attack = randi_range(attack_min, attack_max)
	defence = randi_range(defence_min, defence_max)
	crit = randi_range(crit_min, crit_max)
	crit_chance = randi_range(crit_chance_min, crit_chance_max)

# returns normal tile cost unless theres a building on tile then return big num
func get_tile_cost(tile) -> int:
	if tile.has_building:
		return 1000000000
	return tile.cost

func try_start_battle(player):
	if player.in_battle or player.battle_locked:
		return
	if player.currentTile != currentTile:
		return
	
	# Use enemy spawner to find enemies on the tile
	var enemies = get_parent().enemy_spawner.get_enemies_on_tile(currentTile)
	if enemies.is_empty():
		return
	
	var chosen_enemy = enemies[randi() % enemies.size()]
	
	BattleState.enemies_paused = true
	player.in_battle = true
	player.battle_locked = true
	player.current_enemy = chosen_enemy
	player.battle_started.emit()
	player.battle_phase = Player.BattlePhase.PLAYER_TURN
	

func die(player):
	var gold_reward = randi_range(gold_min, gold_max)
	player.gold += gold_reward
	print("Player got ", gold_reward, " gold")
	
	var spawner = get_parent().enemy_spawner
	if spawner:
		spawner.remove_enemy(self)
		
		queue_free()

# battle controls
func attack_player(player):
	if player == null or not player.in_battle:
		return

	var damage = max(1, attack - player.defence)
	player.health -= damage

	print("Enemy hits player for", damage)

	if player.health <= 0:
		player.health = 0
		player.end_battle(false)
	else:
		player.battle_phase = Player.BattlePhase.PLAYER_TURN

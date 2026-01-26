extends Node2D

@export var city_sprite: Texture2D
@export var shop_sprite: Texture2D
@export var dungeon_sprite: Texture2D
@export var tower_sprite: Texture2D
@export var castle_sprite: Texture2D

#city stuff
@export var city_reward_items: Array[Item]

#shop stuff
signal shop_entered(stock)
@export var shop_items: Array[Item]

var shop_stock := []


var building_type: String = ""
var currentTile

@onready var sprite: Sprite2D = $Sprite2D

func _ready():
	apply_sprite()

func apply_sprite():
	match building_type:
		"city":
			sprite.texture = city_sprite
		"shop":
			sprite.texture = shop_sprite
		"dungeon":
			sprite.texture = dungeon_sprite
		"tower":
			sprite.texture = tower_sprite
		"castle":
			sprite.texture = castle_sprite

# Optional: still keep the weighted random picker
const BUILDINGS = [
	{ "type": "city",    "weight": 30 },
	{ "type": "shop",    "weight": 15 },
	{ "type": "dungeon", "weight": 20 },
	{ "type": "tower",   "weight": 10 },
	{ "type": "castle",  "weight": 5 }
]

func pick_building_type() -> String:
	var total := 0
	for b in BUILDINGS:
		total += b.weight

	var roll := randi() % total
	var current := 0

	for b in BUILDINGS:
		current += b.weight
		if roll < current:
			return b.type


	return "city"

var visited := false

func interact(player):
	if building_type == "city" and visited:
		return

	if building_type == "city":
		visited = true


	match building_type:
		"city":
			enter_city(player)
		"shop":
			enter_shop(player)
		"dungeon":
			enter_dungeon(player)
		"tower":
			enter_tower(player)
		"castle":
			enter_castle(player)

func enter_city(player):
	if city_reward_items.is_empty():
		print("City has no reward items")
		return
	
	var item: Item = city_reward_items.pick_random()
	player.inventory.add_item(item, 1)
	print("Received item from city:", item.display_name)

func get_item_price(item: Item) -> int:
	if item is ConsumableItem:
		match item.id:
			"small_health_potion":
				return 2
			"medium_health_potion":
				return 5
			"large_health_potion":
				return 10
			"energy_potion":
				return 5
			"mana_potion":
				return 5
			_:
				return 5  # default price for any other consumable
	elif item is WeaponItem:
		return 25
	elif item is ArmourItem:
		return 15
	return 10



func enter_shop(player):
	var stock := []
	
	for i in range(3):
		var item: Item = shop_items.pick_random()
		var amount := 1
	
		# Consumables have a stock of 20
		if item is ConsumableItem:
			amount = 20
	
		stock.append({
			"item": item,
			"amount": amount,
			"price": get_item_price(item)  # per-unit price
		})
	
	# Emit signal to overlay to show shop
	emit_signal("shop_entered", stock)


func enter_dungeon(player):
	print("Entered dungeon (battle later)")

func enter_tower(player):
	print("Entered tower (logic later)")

func enter_castle(player):
	print("Entered castle (logic later)")

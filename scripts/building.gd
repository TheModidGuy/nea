extends Node2D

@export var city_sprite: Texture2D
@export var shop_sprite: Texture2D
@export var dungeon_sprite: Texture2D
@export var tower_sprite: Texture2D
@export var castle_sprite: Texture2D

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

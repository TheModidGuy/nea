@tool
extends Node2D

@onready var sprite_2d: Sprite2D = $Sprite2D

var neighbors: Array = []
var cost: int = 0
var grid_x: int = 0
var grid_y: int = 0

# Terrain presets (sprite + cost)
var TERRAIN_PRESETS = {
	"grass": {"spritePath": "res://Assets/Sprites/Tiles/grass.png", "cost": 2},
	"water": {"spritePath": "res://Assets/Sprites/Tiles/water.png", "cost": 5},
	"snow": {"spritePath": "res://Assets/Sprites/Tiles/snow.png", "cost": 4},
	"mountain": {"spritePath": "res://Assets/Sprites/Tiles/mountain.png", "cost": 10}
}

# Exported terrain type with setter
@export var terrainType: String = "grass" : set = set_terrain

# Track last applied terrain to prevent double application
var _last_applied: String = ""

func _ready():
	# Only apply terrain at runtime
	if not Engine.is_editor_hint():
		apply_terrain(terrainType)

# Editor-safe setter
func set_terrain(value: String) -> void:
	if value == _last_applied:
		return # Prevent duplicate application
	terrainType = value
	apply_terrain(value)

func apply_terrain(t_type: String) -> void:
	if TERRAIN_PRESETS.has(t_type):
		var preset = TERRAIN_PRESETS[t_type]

		# Apply sprite if node exists
		if sprite_2d != null:
			sprite_2d.texture = load(preset["spritePath"])

		# Apply other terrain variables
		cost = preset.get("cost", 0)

		_last_applied = t_type
		#print("Applied terrain:", t_type, " cost:", cost)
	else:
		push_error("Unknown terrain type: %s" % t_type)

extends Sprite2D

@onready var label_tile_type: Label = $Label_TileType
@onready var label_movement_cost: Label = $Label_MovementCost
@onready var label_position: Label = $Label_Position
@onready var label_resource: Label = $Label_Resource

func _ready():
	add_to_group("OverlayUI")

func update_tile_info(tile):
	if tile == null:
		clear_info()
		return
	label_tile_type.text = "Terrain: %s" % tile.terrainType.capitalize()
	label_movement_cost.text = "Cost to Move: %d" % tile.cost
	label_position.text = "Grid Position: (%d, %d)" % [tile.grid_x, tile.grid_y]
	
	# Resources: 
	#if tile.has_meta("resource") and tile.get_meta("resource") != "":
		#label_resource.text = "Resource: %s" % str(tile.get_meta("resource"))
	#else:
		#label_resource.text = "Resource: None"

func clear_info():
	label_tile_type.text = ""
	label_movement_cost.text = ""
	label_position.text = ""
	label_resource.text = ""

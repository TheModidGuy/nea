extends Control


signal move_requested

var map: Node = null


@onready var label_tile_type: Label = $TextureRect/Label_TileType
@onready var label_movement_cost: Label = $TextureRect/Label_MovementCost
@onready var label_position: Label = $TextureRect/Label_Position
@onready var label_resource: Label = $TextureRect/Label_Resource

func _ready():
	add_to_group("OverlayUI")


func update_tile_info(tile):
	if tile == null:
		clear_info()
		return
	label_tile_type.text = "Terrain: %s" % tile.terrainType.capitalize()
	label_movement_cost.text = "Cost to Move: %d" % tile.cost
	label_position.text = "Grid Position: (%d, %d)" % [tile.grid_x, tile.grid_y]
	
	if tile.has_building:
		label_resource.text = "Building: %s" % tile.building_on_tile.capitalize()
	else:
		label_resource.text = "Building: None"


func clear_info():
	label_tile_type.text = ""
	label_movement_cost.text = ""
	label_position.text = ""
	label_resource.text = ""


func _on_move_button_pressed() -> void:
	emit_signal("move_requested")
	#if map == null:
		#return
#
	#var tile_to_move = map.last_highlighted_tile
	#if tile_to_move == null:
		#print("No tile selected")
		#return
#
	#var player = map.player_instance
	#if player == null:
		#print("Player not found")
		#return
	#
	## Enforce neighbour rule
	#var current_tile = player.currentTile
	#if tile_to_move not in current_tile.neighbors:
		#print("Tile not adjacent")
		#return
		#
	#map.move_player_to(tile_to_move)

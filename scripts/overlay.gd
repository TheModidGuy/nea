extends Sprite2D

var map: Node = null

@onready var label_tile_type: Label = $Label_TileType
@onready var label_movement_cost: Label = $Label_MovementCost
@onready var label_position: Label = $Label_Position
@onready var label_resource: Label = $Label_Resource

func _ready():
	add_to_group("OverlayUI")

func _unhandled_input(event):
	if event.is_action_pressed("player_move"):
		_on_move_button_pressed()

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


func _on_move_button_pressed() -> void:
	if map == null:
		return

	var tile_to_move = map.last_highlighted_tile
	if tile_to_move == null:
		print("No tile selected")
		return

	var player = map.player_instance
	if player == null:
		print("Player not found")
		return
	
	# Enforce neighbour rule
	var current_tile = player.currentTile
	if tile_to_move not in current_tile.neighbors:
		print("Tile not adjacent")
		return
		
	map.move_player_to(tile_to_move)

extends Control


signal move_requested

var map: Node = null


@onready var label_tile_type: Label = $TextureRect/Label_TileType
@onready var label_movement_cost: Label = $TextureRect/Label_MovementCost
@onready var label_position: Label = $TextureRect/Label_Position
@onready var label_resource: Label = $TextureRect/Label_Resource

# player stats
@onready var label_health: Label = $TextureRect/Label_Health
@onready var label_attack: Label = $TextureRect/Label_Attack
@onready var label_defence: Label = $TextureRect/Label_Defence
@onready var label_speed: Label = $TextureRect/Label_Speed
@onready var label_magic: Label = $TextureRect/Label_Magic
@onready var label_crit: Label = $TextureRect/Label_Crit
@onready var label_gold: Label = $TextureRect/Label_Gold

@onready var inventory_list: VBoxContainer = $ScrollContainer/VBoxContainer
var inventory: Inventory = null

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



func bind_inventory(inv: Inventory):
	if inventory:
		inventory.changed.disconnect(refresh)

	inventory = inv
	inventory.changed.connect(refresh)
	refresh()

func refresh():
	# Clear UI
	for c in inventory_list.get_children():
		c.queue_free()

	if inventory == null:
		return

	for i in range(inventory.slots.size()):
		var slot = inventory.slots[i]
		if slot == null:
			continue

		var btn := Button.new()
		btn.text = "%s x%d" % [
			slot.item.display_name,
			slot.amount
		]
		btn.pressed.connect(_on_item_pressed.bind(i))
		inventory_list.add_child(btn)

func _on_item_pressed(index: int):
	print("Selected inventory slot:", index)

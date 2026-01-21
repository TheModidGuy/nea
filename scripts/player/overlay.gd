extends Control


signal move_requested

var map: Node = null
var player: Node = null

var selected_index: int = -1


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
@onready var label_energy: Label = $TextureRect/Label_Energy
@onready var label_gold: Label = $TextureRect/Label_Gold

@onready var inventory_list: VBoxContainer = $ScrollContainer/VBoxContainer
var inventory: Inventory = null

func _ready():
	add_to_group("OverlayUI")

func _process(_delta):
	update_player_stats()


func update_player_stats():
	if player == null:
		return

	label_health.text = "Health: %d" % player.health
	label_attack.text = "Attack: %d" % player.attack
	label_defence.text = "Defence: %d" % player.defence
	label_speed.text = "Speed: %d" % player.speed
	label_magic.text = "Magic: %d" % player.magic_skill
	label_crit.text = "Crit: %d" % player.crit
	label_energy.text = "Energy: %d" % player.energy
	label_gold.text = "Gold: %d" % player.gold


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


func _on_use_button_pressed():
	if selected_index == -1 or inventory == null or player == null:
		return

	player.use_item_from_inventory(selected_index)
	selected_index = -1


func _on_drop_button_pressed():
	if selected_index == -1 or inventory == null:
		return

	inventory.remove_item(selected_index, 1)
	selected_index = -1


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
	selected_index = index
	print("Selected inventory slot:", index)

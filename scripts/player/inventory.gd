extends Node
class_name Inventory

signal changed

@export var size: int = 50

# Each slot is either null or:
# { "item": Item, "amount": int }
var slots: Array = []


func _ready():
	slots.resize(size)
	for i in range(size):
		slots[i] = null


func add_item(item: Item, amount := 1) -> bool:
	# Try stacking first
	for i in range(size):
		var slot = slots[i]
		if slot and slot.item == item and slot.amount < item.max_stack:
			var can_add = min(amount, item.max_stack - slot.amount)
			slot.amount += can_add
			amount -= can_add
			if amount <= 0:
				changed.emit()
				return true
	
	# Then empty slots
	for i in range(size):
		if slots[i] == null:
			var to_add = min(amount, item.max_stack)
			slots[i] = {
				"item": item,
				"amount": to_add
			}
			amount -= to_add
			if amount <= 0:
				changed.emit()
				return true
	
	changed.emit()
	return false


func remove_item(index: int, amount := 1):
	if index < 0 or index >= size:
		return
	
	var slot = slots[index]
	if slot == null:
		return
	
	slot.amount -= amount
	if slot.amount <= 0:
		slots[index] = null
	
	changed.emit()


func get_item_count(item: Item) -> int:
	var total := 0
	for slot in slots:
		if slot and slot.item == item:
			total += slot.amount
	return total

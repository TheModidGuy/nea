extends Resource
class_name Item

@export var id: String
@export var display_name: String
@export var max_stack: int = 1
@export var description: String

# parent class of all items, it's a resources so all the items I make will be these .tres files.

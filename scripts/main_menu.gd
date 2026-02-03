extends Control

@onready var import_text: TextEdit = $ImportTextEdit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# start
func _on_start_button_pressed() -> void:
	print("Start pressed")
	get_tree().change_scene_to_file("res://Scene/Map/Game.tscn")

# quit
func _on_quit_button_pressed() -> void:
	print("Quit pressed")
	get_tree().quit()

func _on_ImportMapBtn_pressed():
	var text := import_text.text.strip_edges()

	if text.is_empty():
		print("No map string entered")
		return

	SaveBuffer.pending_map_string = text
	get_tree().change_scene_to_file("res://Scene/Map/Game.tscn")

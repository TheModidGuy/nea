extends Control


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

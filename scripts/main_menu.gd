extends Control

func _ready() -> void:
	# Ensure the menu is visible and interactive
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_start_button_pressed() -> void:
	# Change to the main game scene
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_pressed() -> void:
	# Quit the game
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	# TODO: Implement settings menu
	pass

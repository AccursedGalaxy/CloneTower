extends Control
class_name EscapeMenu

signal resume_game
signal return_to_main_menu
signal quit_game

func _ready() -> void:
	# Make sure the menu can process while game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Hide menu initially
	hide()

	# Set up layout
	set_anchors_preset(Control.PRESET_FULL_RECT)
	position = Vector2.ZERO
	size = get_viewport().size

	# Connect to window resize
	get_tree().root.size_changed.connect(_on_window_resize)

func _on_window_resize() -> void:
	size = get_viewport().size

func show_menu() -> void:
	show()
	get_tree().paused = true

func hide_menu() -> void:
	hide()
	get_tree().paused = false

func _on_resume_button_pressed() -> void:
	print("[EscapeMenu] Resume button pressed")
	hide_menu()
	resume_game.emit()

func _on_main_menu_button_pressed() -> void:
	print("[EscapeMenu] Main menu button pressed")
	hide_menu()
	return_to_main_menu.emit()

func _on_quit_button_pressed() -> void:
	print("[EscapeMenu] Quit button pressed")
	get_tree().paused = false  # Unpause before quitting
	quit_game.emit()

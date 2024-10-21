extends Button

@onready var pause_menu: Control = $/root/MainScene/UI/PauseMenu
@onready var game_ui: Control = $/root/MainScene/UI/Menu

# If this button is pressed, show the pause menu
func _on_pressed() -> void:
	# pause the game (for real, not just animation)
	get_tree().paused = true

	game_ui.hide()
	pause_menu.show()

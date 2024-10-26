extends Button

@onready var pause_menu: Control = $/root/MainScene/UI/PauseMenu

# If this button is pressed, show the pause menu
func _on_pressed() -> void:
	# pause the game (for real, not just animation)
	get_tree().paused = true

	get_parent().hide()
	pause_menu.show()

extends Button


@onready var pause_menu: Control = $/root/MainScene/UI/PauseMenu
@onready var game_ui: Control = $/root/MainScene/UI/Menu

func _on_pressed() -> void:
	print("Return button pressed")
	pause_menu.hide()
	game_ui.show()
	get_tree().paused = false

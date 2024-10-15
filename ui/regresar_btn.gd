extends Button


@onready var pause_menu: Control = $/root/MainScene/UI/PauseMenu
@onready var game_ui: Control = $/root/MainScene/UI/Menu

func _on_pressed() -> void:
	print("Pause button pressed")
	pause_menu.hide()
	game_ui.show()
	self.disabled = true
	get_tree().paused = false

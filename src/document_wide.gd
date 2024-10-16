extends Control

@onready var return_btn: Button = get_node("ReturnBtn")
@onready var game_ui: Control = $/root/MainScene/UI/Menu

func _ready() -> void:
	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed() -> void:
	# Hide itself and show the game UI
	game_ui.show()
	self.hide()
	get_tree().paused = false

extends Area2D

# If clicked, the node /root/MainScene/UI/DocumentWide will be shown and the game will be paused

@onready var game_ui = get_node("/root/MainScene/UI/Menu")

func _ready() -> void:
	set_pickable(true)
	connect("input_event", Callable(self, "_on_input_event"))

func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("DocumentWide trigger clicked")
			var document_wide = get_node("/root/MainScene/UI/DocumentWide")
			game_ui.hide()
			document_wide.show()
			get_tree().paused = true

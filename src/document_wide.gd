extends Control

@onready var return_btn: Button = get_node("ReturnBtn")
@onready var game_ui: Control = $/root/MainScene/UI/Menu
@onready var document_sprite: Sprite2D = $DocumentSprite
@onready var texture_object: Texture = null

func _ready() -> void:
	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed() -> void:
	# Hide itself and show the game UI
	game_ui.show()
	self.hide()
	get_tree().paused = false

func show_object(path: String) -> void:
	if path != "":
		texture_object = load(path)
	document_sprite.texture = texture_object
	game_ui.hide()
	self.show()
	get_tree().paused = true

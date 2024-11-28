extends Control

@onready var return_btn: Button = get_node("ReturnBtn")
@onready var game_ui: Control = %GameUI
@onready var document_sprite: Sprite2D = $DocumentSprite
@onready var texture_object: Texture = null

func _ready() -> void:
	return_btn.connect("pressed", Callable(self, "_on_return_pressed"))

func _on_return_pressed() -> void:
	# Hide itself and show the game UI
	game_ui.show()
	self.hide()
	get_tree().paused = false

func show_object(path, dialogue_controller, dialogue_resource, starting_point):
	if path != "":
		texture_object = load(path)
	document_sprite.texture = texture_object
	game_ui.hide()
	self.show()

	if dialogue_resource and starting_point != "":
		await get_tree().create_timer(0.1).timeout
		dialogue_controller.dialogue = dialogue_resource
		dialogue_controller.start_dialogue(starting_point)

	get_tree().paused = true

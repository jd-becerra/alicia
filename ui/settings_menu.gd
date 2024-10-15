extends Control

# Right now, both buttons redirect to the main menu
@onready var guardar_cambios_btn: Button = get_node("ColorRect/GuardarBtn")
@onready var cancelar_btn: Button = get_node("ColorRect/CancelarBtn")

@onready var game_ui: Control = $/root/MainScene/UI/Menu

func _ready() -> void:
	print(self.name)

	guardar_cambios_btn.connect("pressed", Callable(self, "_on_guardar_cambios_pressed"))
	cancelar_btn.connect("pressed", Callable(self, "_on_cancelar_pressed"))

func _on_guardar_cambios_pressed() -> void:
	redirect_main_menu()

func _on_cancelar_pressed() -> void:
	redirect_main_menu()

func redirect_main_menu():
	game_ui.show()
	self.hide()
	get_tree().paused = false

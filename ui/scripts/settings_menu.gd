extends Control

# Right now, both buttons redirect to the main menu
@onready var guardar_cambios_btn: Button = get_node("ColorRect/GuardarBtn")
@onready var cancelar_btn: Button = get_node("ColorRect/CancelarBtn")
@onready var audio: AudioStreamPlayer = get_tree().current_scene.get_node("%SFX")

@export var main_ui: Control


func _ready() -> void:
	print(self.name)

	guardar_cambios_btn.connect("pressed", Callable(self, "_on_guardar_cambios_pressed"))
	cancelar_btn.connect("pressed", Callable(self, "_on_cancelar_pressed"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			play_click_sound()

func _on_guardar_cambios_pressed() -> void:
	redirect_main_menu()

func _on_cancelar_pressed() -> void:
	redirect_main_menu()

func redirect_main_menu():
	self.hide()
	main_ui.show()

func play_click_sound():
	audio.stream = load("res://sounds/click.mp3")
	audio.play()
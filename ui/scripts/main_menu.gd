extends Control

@onready var continuar_btn: Button = %CargarPartidaBtn
@onready var nueva_partida_btn: Button = %NuevaPartidaBtn
@onready var configuracion_btn: Button = %ConfigBtn
@onready var salir_btn: Button = %SalirBtn
@onready var settings_menu: Control = %SettingsMenu

@onready var level_1 = preload("res://scenes/scene_1.tscn")
@onready var audio: AudioStreamPlayer = %SFX

func _ready() -> void:
	print(self.name)

	continuar_btn.connect("pressed", Callable(self, "_on_continuar_pressed"))
	nueva_partida_btn.connect("pressed", Callable(self, "_on_nueva_partida_pressed"))
	configuracion_btn.connect("pressed", Callable(self, "_on_configuracion_pressed"))
	salir_btn.connect("pressed", Callable(self, "_on_salir_pressed"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			play_click_sound()

# Continuar and Nueva Partida buttons will redirect to the game scene
func _on_continuar_pressed() -> void:
	# Remove current scene and load the game scene
	get_tree().change_scene_to_file("res://scenes/scene_1.tscn")
func _on_nueva_partida_pressed() -> void:
	# Remove current scene and load the game scene
	get_tree().change_scene_to_file("res://scenes/scene_1.tscn")

func _on_configuracion_pressed() -> void:
	settings_menu.show()

# Salir button will close the game
func _on_salir_pressed() -> void:
	get_tree().quit()

func play_click_sound():
	audio.stream = load("res://sounds/click.mp3")
	audio.play()

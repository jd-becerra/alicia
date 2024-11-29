extends Control

@onready var guardar_partida_btn: Button = %GuardarBtn
@onready var configuracion_btn: Button = %ConfigBtn
@onready var salir_btn: Button = %SalirBtn
@onready var regresar_btn: Button = %RegresarBtn

@onready var game_ui: Control = %GameUI
@onready var settings_menu: Control = $/root/MainScene/UI/SettingsMenu

var is_paused: bool = false

func _ready() -> void:
	regresar_btn.connect("pressed", Callable(self, "_on_regresar_pressed"))
	configuracion_btn.connect("pressed", Callable(self, "_on_configuracion_pressed"))
	salir_btn.connect("pressed", Callable(self, "_on_salir_pressed"))
	%TutorialBtn.pressed.connect(_on_tutorial_pressed)
	%TutorialClose.pressed.connect(close_tutorial)

func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed("ui_cancel"):
		if is_paused:
			game_ui.show()
			self.hide()
			get_tree().paused = false
		else:
			game_ui.hide()
			self.show()
			get_tree().paused = true
		is_paused = not is_paused

func _on_regresar_pressed() -> void:
	play_click_sound()
	game_ui.show()
	self.hide()
	get_tree().paused = false

func _on_configuracion_pressed() -> void:
	play_click_sound()
	game_ui.hide()
	settings_menu.show()

func _on_salir_pressed() -> void:
	play_click_sound()

	# Return all shader values to their default values
	for node in get_tree().get_nodes_in_group("grayscale"):
		node.material.set_shader_parameter("activate", false)
		node.material.set_shader_parameter("strength", 0.002)

	$/root/MainScene.exited_scene = true
	# Return to the main menu (remember to unpause the game so the menu is responsive again)
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ui/main_menu.tscn")

func play_click_sound():
	var sfx: AudioStreamPlayer = $"/root/MainScene/SFX"
	sfx.stream = load("res://sounds/click.mp3")
	sfx.play()

func _on_tutorial_pressed() -> void:
	%TutorialBtn.hide()
	%Tutorial.show()

func close_tutorial() -> void:
	%Tutorial.hide()
	%TutorialBtn.show()
extends Control

@onready var continuar_btn: Button = %CargarPartidaBtn
@onready var nueva_partida_btn: Button = %NuevaPartidaBtn
@onready var configuracion_btn: Button = %ConfigBtn
@onready var salir_btn: Button = %SalirBtn
@onready var settings_menu: Control = %SettingsMenu
@onready var loading_screen: Control = %LoadingScreen
@onready var loading_progress_bar: ProgressBar = loading_screen.get_node("%LoadingProgress")

@onready var level_1_path = "res://scenes/scene_1.tscn"
@onready var audio: AudioStreamPlayer = %SFX

var loading = false
func _ready() -> void:
	continuar_btn.connect("pressed", Callable(self, "_on_continuar_pressed"))
	nueva_partida_btn.connect("pressed", Callable(self, "_on_nueva_partida_pressed"))
	configuracion_btn.connect("pressed", Callable(self, "_on_configuracion_pressed"))
	salir_btn.connect("pressed", Callable(self, "_on_salir_pressed"))
	%TutorialBtn.pressed.connect(_on_tutorial_pressed)
	%TutorialClose.pressed.connect(close_tutorial)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed:
			play_click_sound()

# Continuar and Nueva Partida buttons will redirect to the game scene
func _on_continuar_pressed() -> void:
	start_loading(level_1_path)
func _on_nueva_partida_pressed() -> void:
	start_loading(level_1_path)

func start_loading(next_scene: String) -> void:
	# Hide everything else and show the loading screen
	settings_menu.hide()
	%Main.hide()
	%Tutorial.hide()
	loading_screen.show()
	ResourceLoader.load_threaded_request(next_scene)
	loading = true
func _process(delta):
	if loading: 
		var progress = []
		ResourceLoader.load_threaded_get_status(level_1_path, progress)
		# Print the progress of the loading
		loading_progress_bar.value = progress[0]*100
		
		if progress[0] == 1:
			loading = false
			var packed_scene = ResourceLoader.load_threaded_get(level_1_path)
			get_tree().change_scene_to_packed(packed_scene)

func _on_configuracion_pressed() -> void:
	settings_menu.show()

# Salir button will close the game
func _on_salir_pressed() -> void:
	get_tree().quit()

func play_click_sound():
	audio.stream = load("res://sounds/click.mp3")
	audio.play()

func _on_tutorial_pressed() -> void:
	%TutorialBtn.hide()
	%Tutorial.show()

func close_tutorial() -> void:
	%Tutorial.hide()
	%TutorialBtn.show()

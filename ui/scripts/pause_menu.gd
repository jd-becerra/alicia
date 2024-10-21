extends Control

@onready var guardar_partida_btn: Button = %GuardarBtn
@onready var configuracion_btn: Button = %ConfigBtn
@onready var salir_btn: Button = %SalirBtn
@onready var regresar_btn: Button = %RegresarBtn

@onready var game_ui: Control = $/root/MainScene/UI/Menu
@onready var settings_menu: Control = $/root/MainScene/UI/SettingsMenu

func _ready() -> void:
    regresar_btn.connect("pressed", Callable(self, "_on_regresar_pressed"))
    configuracion_btn.connect("pressed", Callable(self, "_on_configuracion_pressed"))
    salir_btn.connect("pressed", Callable(self, "_on_salir_pressed"))

func _on_regresar_pressed() -> void:
    game_ui.show()
    self.hide()
    get_tree().paused = false

func _on_configuracion_pressed() -> void:
    game_ui.hide()
    settings_menu.show()

func _on_salir_pressed() -> void:
    # Return to the main menu (remember to unpause the game so the menu is responsive again)
    get_tree().paused = false
    get_tree().change_scene_to_file("res://ui/main_menu.tscn")



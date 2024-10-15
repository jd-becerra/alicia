extends Control

@onready var guardar_partida_btn: Button = self.find_child("GuardarBtn")
@onready var configuracion_btn: Button = self.find_child("ConfigBtn")
@onready var salir_btn: Button = self.find_child("SalirBtn")
@onready var regresar_btn: Button = self.find_child("RegresarBtn")

@onready var game_ui: Control = $/root/MainScene/UI/Menu
@onready var settings_menu: Control = $/root/MainScene/UI/SettingsMenu

func _ready() -> void:
    regresar_btn.connect("pressed", Callable(self, "_on_regresar_pressed"))
    configuracion_btn.connect("pressed", Callable(self, "_on_configuracion_pressed"))

func _on_regresar_pressed() -> void:
    game_ui.show()
    self.hide()
    get_tree().paused = false

func _on_configuracion_pressed() -> void:
    game_ui.hide()
    settings_menu.show()




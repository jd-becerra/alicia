extends Control

@onready var guardar_partida_btn: Button = self.find_child("GuardarBtn")
@onready var configuracion_btn: Button = self.find_child("ConfigBtn")
@onready var salir_btn: Button = self.find_child("SalirBtn")
@onready var regresar_btn: Button = self.find_child("RegresarBtn")

@onready var settings_btn: Button = get_tree().get_root().find_node("Settings", true)
@onready var game_ui: Control = $/root/MainScene/UI/Menu




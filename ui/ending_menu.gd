extends Control

@onready var salir_btn: Button = %SalirBtn

func _ready() -> void:
    salir_btn.connect("pressed", Callable(self, "_on_salir_pressed"))

func _on_salir_pressed() -> void:
    # Return to the main menu (remember to unpause the game so the menu is responsive again)
    get_tree().paused = false
    print("Returning to the main menu")
    get_tree().change_scene_to_file("res://ui/main_menu.tscn")
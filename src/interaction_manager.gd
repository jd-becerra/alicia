extends Node

# Controls all the InteractionChoices Node menus
@onready var game_ui = get_tree().get_root().get_node("MainScene").get_node("%GameUI")
var active_menu = null



func set_active_menu(menu: Control) -> void:
	if active_menu != menu and active_menu:
		# Hide the active menu if is not the same as the new menu
		active_menu.hide_choices()
	active_menu = menu













# func _ready() -> void:
	# Detect on gui input if the mouse is inside the area 
	# game_ui.connect("gui_input", Callable(self, "_on_gui_input"))


# func _on_gui_input(_event: InputEvent) -> void:
# 	if active_menu:
# 		# If active_menu.mouse_inside_area is false, hide the active menu
# 		if not active_menu.mouse_inside_area:
# 			print("Hiding active menu")
# 			active_menu.hide_choices()

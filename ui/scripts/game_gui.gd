extends Control

@export var top_closed_height: int = 24
@export var top_open_height: int = 136

@onready var settings_btn: Button = %Settings
@onready var top: Panel = %Top
@onready var inventory: Control = $"/root/MainScene/UI/Menu/Inventory"

var can_show_inventory = false

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	top.mouse_entered.connect(_on_Top_mouse_entered)
# 	top.mouse_exited.connect(_on_Top_mouse_exited)

func _process(_delta: float) -> void:
	# If mouse hovers on the region of the top panel, show the settings button
	if top.get_global_rect().has_point(get_viewport().get_mouse_position()):
		top.size.y = top_open_height
		settings_btn.show()
		if can_show_inventory:
			inventory.show()
			top.modulate.a = 1.0
		else:
			top.modulate.a = 0.0
	else:
		top.size.y = top_closed_height
		settings_btn.hide()
		inventory.hide()
		if not can_show_inventory:
			top.modulate.a = 0.5

func _on_Top_mouse_entered() -> void:
	top.size.y = top_open_height

	settings_btn.show()
	if can_show_inventory:
		inventory.show()

func _on_Top_mouse_exited() -> void:
	top.size.y = top_closed_height

	settings_btn.hide()
	inventory.hide()
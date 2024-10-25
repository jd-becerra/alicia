extends Control

@export var top_closed_height: int = 24
@export var top_open_height: int = 136

@onready var settings_btn: Button = $"/root/MainScene/UI/Menu/Settings"
@onready var top: Panel = %Top
@onready var toggle_inventory_btn: Button = %ToggleInventoryBtn
@onready var inventory: Control = %Inventory

var can_show_inventory = false
var show_inventory = false
var toggle_btn_offset = 5

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	top.mouse_entered.connect(_on_Top_mouse_entered)
# 	top.mouse_exited.connect(_on_Top_mouse_exited)

func _ready() -> void:
	toggle_inventory_btn.position.y = top_closed_height + toggle_btn_offset
	toggle_inventory_btn.pressed.connect(toggle_inventory)

func toggle_inventory() -> void:
	if show_inventory:
		close_ui()
	else:
		open_ui()

func open_ui() -> void:
	top.size.y = top_open_height
	# make toggle_inventory_btn position under top
	toggle_inventory_btn.position.y = top_open_height + toggle_btn_offset

	settings_btn.show()

	if can_show_inventory:
		inventory.show()
		top.modulate.a = 1
	else:
		# If can_show_inventory is false, only show settings_btn and make top transparent
		top.modulate.a = 0

	show_inventory = true

func close_ui() -> void:
	top.size.y = top_closed_height
	toggle_inventory_btn.position.y = top_closed_height + toggle_btn_offset

	settings_btn.hide()
	inventory.hide()

	show_inventory = false
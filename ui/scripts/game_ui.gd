extends Control

@export var top_closed_height: int = 24
@export var top_open_height: int = 136

@onready var settings_btn: Button = %Settings
@onready var top: Panel = %Top
@onready var toggle_inventory_btn: Button = %ToggleInventoryBtn
@onready var inventory: Control = %Inventory

@onready var player: CharacterBody2D = $"/root/MainScene/Player"
@onready var grabbed_slot: PanelContainer = %GrabbedSlot

var can_show_inventory = false
var show_inventory = false
var toggle_btn_offset = 5

var grabbed_item: Item = null
var inventory_data: Inventory = null
var slot_mouse_offset: Vector2 = Vector2(-48, -48)

# Called when the node enters the scene tree for the first time.
# func _ready() -> void:
# 	top.mouse_entered.connect(_on_Top_mouse_entered)
# 	top.mouse_exited.connect(_on_Top_mouse_exited)

func _ready() -> void:
	toggle_inventory_btn.position.y = top_closed_height + toggle_btn_offset
	toggle_inventory_btn.pressed.connect(toggle_inventory)
	set_inventory_data()

	# Make the margin of grabbed_slot 0
	grabbed_slot.resize_margin(0)

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		# Set position of the grabbed slot to the global mouse position 
		grabbed_slot.global_position = get_viewport().get_mouse_position() + slot_mouse_offset
	if show_inventory and can_show_inventory and not inventory.visible:
		inventory.show()
		top.modulate.a = 1
	if not can_show_inventory and inventory.visible:
		inventory.hide()
		top.modulate.a = 0

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

func set_inventory_data() -> void:
	inventory_data = player.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory.set_inventory_data(inventory_data)

func on_inventory_interact(inv: Inventory, item: Item, index: int, button_action: int) -> void:
	if button_action: # true for pressed, false for released
		# Grab item if clicked (check that the new item is not null)
		if inv.items[index]:
			grabbed_item = inv.grab_item(index)
	else: # Release item if released
		inv.release_item(grabbed_item, item, index, grabbed_slot)
		grabbed_item = null
	update_grab_slot()

func update_grab_slot() -> void:
	if grabbed_item:
		grabbed_slot.set_data(grabbed_item)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()

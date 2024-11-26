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
	play_swipe_sound()
	if show_inventory:
		close_ui()
	else:
		open_ui()

func open_ui() -> void:
	%Animations.play("Open_Inventory")

	settings_btn.show()

	if can_show_inventory:
		inventory.show()
		top.modulate.a = 1
	else:
		# If can_show_inventory is false, only show settings_btn and make top transparent
		top.modulate.a = 0

	show_inventory = true

func close_ui() -> void:
	%Animations.play("Close_Inventory")

	settings_btn.hide()
	inventory.hide()

	show_inventory = false

func set_inventory_data() -> void:
	inventory_data = player.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)

	var full_inventory = get_node("/root/MainScene").get_node("%InteractionManager").full_inventory
	full_inventory.initialize_indices()

	for f_item in full_inventory.items:
		if f_item.default:
			inventory_data.add_item(f_item.index, f_item)

	inventory.set_inventory_data(inventory_data)

func on_inventory_interact(inv: Inventory, item: Item, index: int, button_action: int) -> void:
	# 0 - MOUSE_BUTTON_LEFT released
	# 1 - MOUSE_BUTTON_LEFT pressed
	# 2 - MOUSE_BUTTON_RIGHT (pressed)
	play_click_sound()
	
	if button_action == 1:
		# Grab item if clicked (check that the new item is not null)
		if inv.items[index]:
			grabbed_item = inv.grab_item(index)
		update_grab_slot()
	elif button_action == 0:
		inv.release_item(grabbed_item, index)
		grabbed_item = null
		update_grab_slot()
	elif button_action == 2:
		if inv.items[index]:
			if inv.items[index].is_document:
				zoom_document(inv.items[index].document_path)
			else:
				# Start dialogue about the item
				pass

		# This action is to USE, INSPECT or ZOOM IN the item on the inventory (depending on the item)
		print("Right click on item %s" % item.name)

func update_grab_slot() -> void:
	if grabbed_item:
		grabbed_slot.set_data(grabbed_item)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()

func zoom_document(document_path: String = "") -> void:
	
	var dialogue = null
	if document_path == "res://docs/cartas.jpg":
		dialogue = load("res://dialogue/scene_1/escritorio.dialogue")
	if document_path == "res://assets/objects/scene-1/partitura_wide.png":
		dialogue = load("res://dialogue/scene_1/partitura.dialogue")
	if document_path == "res://docs/testamento.jpg":
		dialogue = load("res://dialogue/scene_1/testamento.dialogue")
	
	var balloon = load("res://dialogue/balloon.tscn").instantiate()
	# get_current_scene().add_child(balloon)
	get_tree().get_root().add_child(balloon)
	balloon.start(dialogue, "Zoom", [])

	var document_wide = get_node("/root/MainScene/UI/DocumentWide")
	document_wide.show_object(document_path)

func play_click_sound():
	var sfx: AudioStreamPlayer = $"/root/MainScene/SFX"
	sfx.stream = load("res://sounds/click.mp3")
	sfx.play()

func play_swipe_sound() -> void:
	var sfx: AudioStreamPlayer = $"/root/MainScene/SFX"
	sfx.stream = load("res://sounds/swipe.mp3")
	sfx.play()
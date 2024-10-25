extends Node
# Global script that handles the inventory system

var grabbed_item: Item = null
var inventory_data: Inventory = null
var slot_mouse_offset: Vector2 = Vector2(5, 5)

@onready var inventory_interface: PanelContainer = $"/root/MainScene/UI/Menu/InventoryUI/Inventory"
@onready var player: CharacterBody2D = $"/root/MainScene/Player"
@onready var grabbed_slot: PanelContainer = $"/root/MainScene/UI/Menu/InventoryUI/GrabbedSlot"

func _ready() -> void:
	# Fill the inventory grid with the player's inventory data when the inventory interface is ready
	inventory_interface.ready.connect(set_inventory_data)

func _physics_process(_delta: float) -> void:
	if grabbed_slot.visible:
		# Set position of the grabbed slot to the global mouse position 
		grabbed_slot.global_position = get_viewport().get_mouse_position() + slot_mouse_offset

func set_inventory_data() -> void:
	inventory_data = player.inventory_data
	inventory_data.inventory_interact.connect(on_inventory_interact)
	inventory_interface.set_inventory_data(inventory_data)

func on_inventory_interact(inv: Inventory, _item: Item, index: int, button_action: int) -> void:
	if button_action: # true for pressed, false for released
		# Grab item if clicked (check that the new item is not null)
		if inv.items[index]:
			grabbed_item = inv.grab_item(index)
	else: # Release item if released
		inv.release_item(grabbed_item, index)
		grabbed_item = null

		
	
	update_grab_slot()

func update_grab_slot() -> void:
	if grabbed_item:
		grabbed_slot.set_data(grabbed_item)
		grabbed_slot.show()
	else:
		grabbed_slot.hide()

extends PanelContainer

const ItemSlot = preload("res://ui/inventory/item_slot.tscn")

@onready var item_grid: GridContainer = %Items

var MAX_ITEMS = 7
var player_inventory_data: Inventory

func _ready() -> void:
	MAX_ITEMS = item_grid.columns
	initialize_inventory()

func initialize_inventory():
	for i in range(0, MAX_ITEMS):
		var item_slot = ItemSlot.instantiate()
		item_grid.add_child(item_slot)

func fill_grid(items: Array):
	for slot_pos in range(0, items.size()):
		var item_slot = item_grid.get_child(slot_pos)
		item_slot.set_data(items[slot_pos])

		item_slot.item_slot_selected.connect(player_inventory_data.on_slot_selected)

func set_inventory_data(inventory: Inventory):
	player_inventory_data = inventory

	if not player_inventory_data or player_inventory_data.items.size() == 0:
		return

	fill_grid(player_inventory_data.items)

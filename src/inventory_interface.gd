extends PanelContainer

const ItemSlot = preload("res://ui/inventory/item_slot.tscn")

@onready var item_grid: GridContainer = $MarginContainer/Items
@onready var data = preload("res://ui/inventory/inventory_scene_1.tres")

var MAX_ITEMS = 7

func _ready() -> void:
	MAX_ITEMS = item_grid.columns
	fill_grid(data.items)

func fill_grid(items: Array):
	for child in item_grid.get_children():
		child.queue_free()

	for slot_pos in range(0, MAX_ITEMS):
		var item_slot = ItemSlot.instantiate()
		item_grid.add_child(item_slot)

		if slot_pos < items.size():
			item_slot.set_data(items[slot_pos])

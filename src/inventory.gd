extends Resource
class_name Inventory

signal inventory_interact(inventory_data: Inventory, item: Item, index: int, button: int)
signal inventory_changed(inventory_data: Inventory)

@export var items: Array = [Item]

func on_slot_selected(item: Item, index: int, button_action: int) -> void:
    inventory_interact.emit(self, item, index, button_action)

func grab_item(index: int) -> Item:
    var item = items[index]
    
    if item:
        items[index] = null
        inventory_changed.emit(items)
        return item
    else:
        return null

func release_item(item: Item, index: int):
    items[index] = item
    inventory_changed.emit(items)

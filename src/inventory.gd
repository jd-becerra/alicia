extends Resource
class_name Inventory

@export var items: Array = [Item]

func on_slot_selected(item: Item, index: int) -> void:
    print("Item %s selected: %s" % [index, item.name])
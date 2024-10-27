extends Button
class_name InteractionObject
# Similar to Item class, but it's a button and doesn't have a texture

var item: Item = null

func _ready() -> void:
    item = Item.new()
    item.name = get_parent().object_name
    # Rest of item data is empty/null since we only need the name
    
extends PanelContainer


@onready var margin_container = $MarginContainer
@onready var texture_rect = margin_container.get_node("TextureRect")
@onready var inventory = get_tree().get_root().get_node("MainScene").get_node("%GameUI/Inventory")

var item_data: Item

@warning_ignore("unused_signal")
signal slot_selected(item: Item, index: int, button: int)

func _ready() -> void:
	gui_input.connect(_on_gui_input)

func set_data(item: Item) -> void:
	if item:
		item_data = item
		texture_rect.texture = item.texture
		tooltip_text = "%s" % item.description
	else:
		item_data = null
		texture_rect.texture = null
		tooltip_text = ""

func _process(_delta: float) -> void:
	# Make texture bigger if mouse is over the item by making the margin smaller
	if is_mouse_over():
		resize_margin(0)
	else:
		resize_margin(8)

func is_mouse_over(node: Node = null) -> bool:
	if node:
		return node.get_global_rect().has_point(get_global_mouse_position())
	else:
		return texture_rect.get_global_rect().has_point(get_viewport().get_mouse_position())

func resize_margin(margin: int) -> void:
	margin_container.add_theme_constant_override("margin_left", margin)
	margin_container.add_theme_constant_override("margin_right", margin)
	margin_container.add_theme_constant_override("margin_top", margin)
	margin_container.add_theme_constant_override("margin_bottom", margin)

func _on_gui_input(event: InputEvent) -> void:
	# Send:
	# 0 - MOUSE_BUTTON_LEFT released
	# 1 - MOUSE_BUTTON_LEFT pressed
	# 2 - MOUSE_BUTTON_RIGHT (pressed)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				slot_selected.emit(self.item_data, get_index(), 1)
			else:
				slot_selected.emit(get_item_under_mouse(), get_index(), 0)
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
				slot_selected.emit(self.item_data, get_index(), 2)

func get_item_under_mouse() -> Item:
	# First search for items in the inventory slots
	for slot in inventory.item_grid.get_children():
		if slot is PanelContainer:
			if slot.is_mouse_over():
				return slot.item_data

	return null
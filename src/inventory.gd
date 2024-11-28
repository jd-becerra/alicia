extends Resource
class_name Inventory

signal inventory_interact(inventory_data: Inventory, item: Item, index: int, button: int)
signal inventory_changed(inventory_data: Inventory)

@export var items: Array[Item] = []
var ITEMS_SIZE = 0

func initialize_indices() -> void:
	if items.size() == 0:
		return

	for i in range(items.size()):
		items[i].index = i

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

func add_item(index: int, new_item: Item) -> void:

	# Mantain the inventory sorted by index

	var insert_pos = 0
	# Find the correct position to insert the new item
	while insert_pos < ITEMS_SIZE and items[insert_pos].index < index:
		insert_pos += 1
		

	# Insert the item at the correct position
	if insert_pos == items.size():
		# If we reached the end, simply append
		items.append(new_item)
	else:
		# Insert at position, shifting everything to the right
		items.append(items[-1])  # Add space at the end
		for i in range(items.size() - 2, insert_pos - 1, -1):
			items[i + 1] = items[i]
		items[insert_pos] = new_item

	ITEMS_SIZE += 1

	inventory_changed.emit(items)

func release_item(grabbed_item: Item, index: int) -> void:
	items[index] = grabbed_item
	inventory_changed.emit(items)

func remove_item(index: int) -> void:
	# items[index] = null
	# inventory_changed.emit(items)

	# Rearrange the items starting from the index to the end
	for i in range(index, items.size() - 1):
		items[i] = items[i + 1]
	items[ITEMS_SIZE - 1] = null
	ITEMS_SIZE -= 1

	inventory_changed.emit(items)

func interaction_object_under(slot: PanelContainer) -> Item:
	var scene_tree: SceneTree = Engine.get_main_loop().current_scene.get_tree()
	var main_scene = scene_tree.get_root().get_node("MainScene")
	var viewport: Viewport = main_scene.get_node("%GameUI").get_viewport()

	var slot_pos = slot.position
	var slot_canvas_pos = viewport.get_screen_transform().basis_xform(slot_pos)
	var tolerance_offset : Vector2 = Vector2(48, 48) # Vertical and horizontal offset (valid for top, bottom, left and right)
	var slot_rect = Rect2(slot_canvas_pos - tolerance_offset / 2, slot.get_size() + tolerance_offset)

	for interaction_menu in scene_tree.get_nodes_in_group("interaction_menu"):
		var dot = interaction_menu.get_node("%OpenWheelBtn")

		if not interaction_menu.visible or not dot.visible:
			continue

		var dot_canvas_pos = viewport.get_screen_transform() * dot.get_global_transform_with_canvas() * dot.position
		if slot_rect.has_point(dot_canvas_pos):
			return dot.item

	return null

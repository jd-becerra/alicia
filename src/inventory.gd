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

func release_item(grabbed_item: Item, target_item: Item, index: int, grabbed_slot: PanelContainer) -> void:
	if target_item:
		print("Released %s item on %s item" % [grabbed_item.name, target_item.name])
	else:
		var object_under = interaction_object_under(grabbed_slot)
		if object_under:
			print("Released %s item on %s object" % [grabbed_item.name, object_under.name])
		else:
			print("Released %s item on empty slot" % grabbed_item.name)

	items[index] = grabbed_item
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

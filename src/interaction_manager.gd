extends Node
# Controls all the InteractionChoices Node menus

## Available items on the scene
@export var full_inventory: Inventory

var main_scene
var player_inventory: Inventory
var game_ui
var game_states
var animation_playing_first_time = true

var active_menu = null
var current_animation_player = null
var is_initialized = false
var volume = -10
var fullscreen = false

func _process(_delta: float) -> void:
	if not get_tree().current_scene:
		return

	if not get_tree().current_scene.name == "MainScene":
		return

	if is_initialized:
		return
		
	main_scene = get_tree().get_root().get_node("MainScene")
	player_inventory = main_scene.get_node("%Player").inventory_data
	game_ui = main_scene.get_node("%GameUI")
	game_states = main_scene.get_node("%States")
	is_initialized = true

func set_active_menu(menu: Control) -> void:
	if active_menu != menu and active_menu:
		# Hide the active menu if is not the same as the new menu
		active_menu.hide_choices()
	active_menu = menu

func play_character_animation(character: String, animation_name: String, play_over_dialogue = false) -> void:
	var route = "/root/MainScene/Characters/" + character
	await play_animation(route, animation_name, play_over_dialogue)

func play_object_animation(object: String, animation_name: String, play_over_dialogue = false) -> void:
	var route = "/root/MainScene/Objects/" + object
	await play_animation(route, animation_name, play_over_dialogue)

func play_animation(controller_route: String, animation_name: String, play_over_dialogue) -> void:	
	var controller = get_node(controller_route)
	var anim_player: AnimationPlayer = controller.get_node("AnimationPlayer")
	current_animation_player = anim_player

	anim_player.play(animation_name)

	if not play_over_dialogue:
		await(anim_player.animation_finished)
		current_animation_player = null

func play_sound(sound: String) -> void:
	var audio: AudioStreamPlayer = get_node("/root/MainScene/SFX")
	audio.stream = load("res://sounds/" + sound)
	audio.play()

func pause_dialogue(time: float) -> void:
	await get_tree().create_timer(time).timeout

func get_item_index(item_name: String) -> int:
	for i in range(full_inventory.items.size()):
		print("Item: ", full_inventory.items[i].name)
		var f_item = full_inventory.items[i]
		if f_item.name == item_name:
			return f_item.index
	return -1

func add_item_to_inventory(item: Item) -> void:
	var item_index = get_item_index(item.name)
	if item_index != -1:
		player_inventory.add_item(item_index, item)

func remove_item_from_inventory(item: Item) -> void:
	# Await for the item to return to the inventory
	await get_tree().create_timer(0.5).timeout
	var item_index = get_item_index(item.name)
	print("Item index: ", item_index)

	if item_index != -1:
		print("Removing: ", item.name,  " from inventory")
		player_inventory.remove_item(item_index)
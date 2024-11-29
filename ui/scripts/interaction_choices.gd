extends Control
# This menu has a dot that scales up if clicked, showing the available 
# interaction choices for a given object.

# Make an array of boolean values to represent the availability of each interaction choice
## Options: [ Inspect, Zoom, Pick Up, Use ]
@export_category("Main settings")
@export var enable_on_scene: bool = true
@export var object_name: String = ""

# Dialogue and animations for all the interactions
@export var dialogue: DialogueResource
@export var animations: AnimationPlayer

@export_category("Choices")
@export var inspect: bool = false
@export var zoom: bool = false
@export var pick_up: bool = false
@export var use: bool = false

@export_category("Zoom")
@export var zoom_object_path: String   # Receives a path to a texture

@export_category("Pick Up")
@export var item_to_pick_up: Item

@export_category("Pick Up")
@export var use_node: Node  # Can be a Control node, a Sprite, etc.

# The dot that scales up when clicked
@onready var dot: Button = %OpenWheelBtn
# The interaction choice buttons
@onready var inspect_button: Button = %InspectBtn
@onready var zoom_button: Button = %ZoomBtn
@onready var pick_up_button: Button = %PickUpBtn
@onready var use_button: Button = %UseBtn
@onready var animation_player: AnimationPlayer = %Animations
@onready var area: Area2D = %AreaDetect
@onready var game_ui: Control = %GameUI

@onready var dot_icon_path: String = "res://ui/icons/dot.png"
@onready var dot_outline_icon_path: String = "res://ui/icons/dot_open.png"

@onready var playback_button: Button = %GameUI/PlaybackButton
@onready var main_scene: Node2D = $"/root/MainScene"

@onready var interaction_manager = get_tree().get_root().get_node("MainScene").get_node("%InteractionManager")
@onready var dialogue_controller: DialogueController = %DialogueController
@onready var game_states = main_scene.get_node("%States")

@warning_ignore("unused_signal")
signal dialogue_active(is_active: bool)
signal unhandled_left_click_release(event: InputEvent)
signal clicked_interaction_button(clicked: bool)

var wheel_open = false
var mouse_inside_area = false
var game_paused = false
var force_disable = false # This will force disabling the menu even if the AnimationPlayer is telling it to show
var force_enable = false # This will force enabling the menu even if the AnimationPlayer is telling it to hide

func _ready() -> void:
	# Connect the dot button to the _on_dot_pressed function
	dot.connect("pressed", Callable(self, "_on_dot_pressed"))
	connect("gui_input", Callable(self, "_on_gui_input"))

	area.mouse_entered.connect(_on_enter_area.bind(true))
	area.mouse_exited.connect(_on_enter_area.bind(false))

	if playback_button:
		playback_button.connect("paused", Callable(self, "on_game_paused"))

	animation_player.connect("animation_finished", Callable(self, "show_buttons"))

	dot.mouse_entered.connect(_on_button_hover.bind(dot))
	dot.mouse_exited.connect(_on_button_exit.bind(dot))
	if inspect:
		inspect_button.pressed.connect(on_inspect)
		inspect_button.mouse_entered.connect(_on_button_hover.bind(inspect_button))
		inspect_button.mouse_exited.connect(_on_button_exit.bind(inspect_button))
	if zoom:
		zoom_button.pressed.connect(on_zoom)
		zoom_button.mouse_entered.connect(_on_button_hover.bind(zoom_button))
		zoom_button.mouse_exited.connect(_on_button_exit.bind(zoom_button))
	if pick_up:
		pick_up_button.pressed.connect(on_pick_up)
		pick_up_button.mouse_entered.connect(_on_button_hover.bind(pick_up_button))
		pick_up_button.mouse_exited.connect(_on_button_exit.bind(pick_up_button))
	if use:
		use_button.pressed.connect(on_use)
		use_button.mouse_entered.connect(_on_button_hover.bind(use_button))
		use_button.mouse_exited.connect(_on_button_exit.bind(use_button))

func _process(_delta: float) -> void:
	if game_paused and enable_on_scene and (not force_disable or force_enable):
		self.show()
		if is_grabbed_slot_over():
			_on_button_hover(dot)
		else:
			_on_button_exit(dot)
	else:
		self.hide()
	if Input.is_action_just_released("click"):
		release_interaction_click()

func _on_dot_pressed() -> void:
	play_sound("swipe.mp3")
	if not wheel_open:
		InteractionManager.set_active_menu(self) # Set this menu as the active one
		show_choices()
	else:
		hide_choices()

func release_interaction_click() -> void:
	emit_signal("clicked_interaction_button", false)

func show_choices() -> void:
	dot.icon = load(dot_outline_icon_path)
	animation_player.play("open_wheel")

	area.set_pickable(true)

	wheel_open = true

func hide_choices() -> void:
	mouse_inside_area = false

	# Stop the animation
	animation_player.stop()

	# Hide the interaction choice buttons
	inspect_button.hide()
	zoom_button.hide()
	pick_up_button.hide()
	use_button.hide()

	# Disable area 
	area.set_pickable(false)

	dot.icon = load(dot_icon_path)
	dot.scale = Vector2(1, 1)

	wheel_open = false

	if InteractionManager.active_menu == self:
		InteractionManager.active_menu = null  # Reset the active menu to empty

func show_buttons(anim_name: String) -> void:
	if anim_name == "open_wheel":
		if inspect:
			inspect_button.show()
		if zoom:
			zoom_button.show()
		if pick_up:
			pick_up_button.show()
		if use:
			use_button.show()
		

func _on_button_hover(btn: Button) -> void:
	mouse_inside_area = true
	if btn == dot and not wheel_open:
		btn.scale = Vector2(1.5, 1.5)
	elif wheel_open:
		btn.scale = Vector2(1.1, 1.1)

func _on_button_exit(btn: Button) -> void:
	mouse_inside_area = false
	if wheel_open or (not wheel_open and btn == dot):
		btn.scale = Vector2(1, 1)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and \
		event.button_index == MOUSE_BUTTON_LEFT and \
		event.pressed == false:
			check_grabbed_slot()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not mouse_inside_area:
					hide_choices()
			elif not event.pressed and dot.get_global_rect().has_point(get_global_mouse_position()):
				unhandled_left_click_release.emit(event, dot.item)

func on_game_paused(state: bool) -> void:
	game_paused = state
	if state and enable_on_scene:
		self.show()
	else:
		self.hide()

func click_inside_menu() -> bool:
	return mouse_inside_area

func click_in_buttons(pos: Vector2) -> bool:
	var check = inspect_button.get_global_rect().has_point(pos) or \
	zoom_button.get_global_rect().has_point(pos) or \
	pick_up_button.get_global_rect().has_point(pos) or \
	use_button.get_global_rect().has_point(pos)
	return check

func _on_enter_area(mouse_inside: bool) -> void:
	if wheel_open and mouse_inside:
		mouse_inside_area = true
	else:
		mouse_inside_area = false

func update_choices(new_inspect: bool, new_zoom: bool, new_pick_up: bool, new_use: bool) -> void:
	inspect = new_inspect
	zoom = new_zoom
	pick_up = new_pick_up
	use = new_use

func on_inspect() -> void:
	emit_signal("clicked_interaction_button", true)
	hide_choices()
	show_interaction_dialogue(dialogue, "Inspect")

func on_zoom() -> void:
	# For now, only show the object texture
	emit_signal("clicked_interaction_button", true)
	hide_choices()
	var document_wide = get_node("/root/MainScene/UI/DocumentWide")
	await get_tree().create_timer(0.1).timeout

	var dialogue_resource = null
	var starting_point = ""

	if object_name == "Escritorio_Interaction":
		dialogue_resource = dialogue
		starting_point = "Zoom"
	if object_name == "Partitura_Interaction":
		dialogue_resource = load("res://dialogue/scene_1/partitura.dialogue")
		starting_point = "Zoom"

	document_wide.show_object(zoom_object_path, dialogue_controller, dialogue_resource, starting_point)

func on_pick_up() -> void:
	emit_signal("clicked_interaction_button", true)
	hide_choices()

	if not item_to_pick_up:
		show_interaction_dialogue(dialogue, "No_Pick_Up")
		return

	disable_action("Pick Up")

	play_pop_sound()

	# If item is "Partitura", force_disable the menu and hide that object from the scene
	if item_to_pick_up.name == "Partitura":
		force_disable = true
		main_scene.get_node("Objects/Partitura").hide()
	
	if item_to_pick_up.name == "Batuta":
		var box = main_scene.get_node("Objects/Box")
		box.texture = load("res://assets/objects/scene-1/box_empty.png")
		self.enable_on_scene = false
	
	if item_to_pick_up.name == "Cartas":
		main_scene.get_node("Objects/Desk").texture = load("res://assets/objects/scene-1/desk_no_papers.png")
		main_scene.get_node("%InteractionMenus/Choices-Papeles").enable_on_scene = false

	# Add the item to the player's inventory
	interaction_manager.add_item_to_inventory(item_to_pick_up)

	if not game_ui.get_node("%Inventory").visible:
		# Disable mouse to avoid grabbing items on animation
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
		game_ui.get_node("%Animations").play("Open_Inventory")
		await get_tree().create_timer(0.8).timeout
		game_ui.get_node("%Animations").play("Close_Inventory")
		# Await animation finished
		await game_ui.get_node("%Animations").animation_finished
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func on_use() -> void:
	emit_signal("clicked_interaction_button", true)
	hide_choices()

	if use_node:
		if object_name == "Piano_Interaction":
			if not game_states.piano_open:
				var piano_anim_player = get_node("/root/MainScene/Objects/Piano/AnimationPlayer")
				# Here we should make a dialogue when Piano is closed
				# show_interaction_dialogue(dialogue, "Piano_Closed")

				# There are two reasions why the piano can't be played:
				# 1. The piano is stuck (closed)
				# 2. The player hasn't put the Batuta item on the piano to keep it from closing
				if piano_anim_player.current_animation == "Stuck":
					show_interaction_dialogue(dialogue, "Piano_Stuck")
				else:
					show_interaction_dialogue(dialogue, "Piano_Closing")
				return
			if not game_states.piano_has_sheet_music:
				# Here we should make a dialogue when Piano has no sheet music
				# show_interaction_dialogue(dialogue, "Piano_No_Sheet_Music")
				show_interaction_dialogue(dialogue, "Piano_No_Sheet_Music")
				return

		game_states.piano_menu_open = true
		use_node.show_use_node()
	else:
		show_interaction_dialogue(dialogue, "No_Use")

func disable_action(action_name: String) -> void:
	match action_name:
		"Inspect":
			inspect_button.hide()
			inspect = false
		"Zoom":
			zoom_button.hide()
			zoom = false
		"Pick Up":
			pick_up_button.hide()
			pick_up = false
		"Use":
			use_button.hide()
			use = false
		_:
			print("Invalid action name")
			pass

func enable_action(action_name: String) -> void:
	match action_name:
		"Inspect":
			inspect_button.show()
			inspect = true
		"Zoom":
			zoom_button.show()
			zoom = true
		"Pick Up":
			pick_up_button.show()
			pick_up = true
		"Use":
			use_button.show()
			use = true
		_:
			print("Invalid action name")
			pass

func show_interaction_dialogue(resource, dialogue_name: String) -> void:
	await get_tree().create_timer(0.1).timeout
	dialogue_controller.dialogue = resource
	dialogue_controller.start_dialogue(dialogue_name)

func is_grabbed_slot_over() -> bool:
	# Improved logic to ensure reliable detection when the grabbed slot is over the dot button
	var mouse_position = get_global_mouse_position()
	if dot.get_global_rect().has_point(mouse_position):
		return true
	return false

func check_grabbed_slot() -> void:
	var grabbed_slot = game_ui.get_node("%GrabbedSlot")
	if grabbed_slot and grabbed_slot.visible and is_grabbed_slot_over():
		check_interactions(game_ui.grabbed_item, dot.item)

func check_interactions(grabbed_item: Item, object_under: Item) -> void:
	if grabbed_item.name == "Partitura" and object_under.name == "Piano_Interaction":
		%SFX2.stream = load("res://sounds/correct.mp3")
		%SFX2.play()
		game_states.piano_has_sheet_music = true
		interaction_manager.remove_item_from_inventory(grabbed_item)
		lock_mouse()
		if not game_states.piano_open:
			get_node("/root/MainScene/Objects/PartituraExtraSmall").show()
			show_interaction_dialogue(dialogue, "Partitura_Piano_Stuck")
		else:
			show_interaction_dialogue(dialogue, "Piano_Correct_Partitura")
	elif grabbed_item.name == "Batuta" and object_under.name == "Piano_Interaction":
		var piano_anim_player = main_scene.get_node("Objects/Piano/AnimationPlayer")
		var flowerpot_anim_player = main_scene.get_node("Objects/FlowerPot/AnimationPlayer")
		if piano_anim_player.current_animation == "RESET" or \
				piano_anim_player.current_animation == "Almost closing" or \
				piano_anim_player.current_animation == "Leaf falls":
			game_states.piano_open = true
			%Sounds/Piano.play()
			%SFX2.stream = load("res://sounds/correct.mp3")
			%SFX2.play()
			piano_anim_player.play("Open")
			flowerpot_anim_player.play("No_Leaf")
			interaction_manager.remove_item_from_inventory(grabbed_item)
			lock_mouse()

			if not game_states.piano_has_sheet_music:
				show_interaction_dialogue(dialogue, "Batuta_Piano_Open")
			else:
				show_interaction_dialogue(dialogue, "Piano_Correct_Batuta")
		else:
			# Dialogue if game_states.piano_open is false
			show_interaction_dialogue(dialogue, "Batuta_Piano_Stuck")
	else:
		# If the items don't match, start a dialogue for the interaction
		var invalid_match_dialogue = "%s_%s" % [grabbed_item.name, object_under.name]
		show_interaction_dialogue(dialogue, invalid_match_dialogue)

func lock_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED_HIDDEN)
	await get_tree().create_timer(1.0).timeout
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func play_sound(sound: String) -> void:
	var sfx: AudioStreamPlayer = $"/root/MainScene/SFX"
	sfx.stream = load("res://sounds/" + sound)
	sfx.play()

func play_pop_sound():
	%SFX2.stream = load("res://sounds/pop.mp3")
	%SFX2.play()
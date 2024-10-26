extends Control
# This menu has a dot that scales up if clicked, showing the available 
# interaction choices for a given object.

# Make an array of boolean values to represent the availability of each interaction choice
## Options: [ Inspect, Zoom, Pick Up, Use ]
@export_category("Main settings")
@export_flags("Inspect:1", "Zoom:2", "PickUp:3", "Use:4") var choices
@export var enable_on_scene: bool = true

@export_category("Inspect")
@export var inspect_dialogue: DialogueResource

@export_category("Zoom")
@export var zoom_dialogue: DialogueResource
@export var zoom_object_path: String   # Receives a path to a texture

# The dot that scales up when clicked
@onready var dot: Button = %OpenWheelBtn
# The interaction choice buttons
@onready var inspect_button: Button = %InspectBtn
@onready var zoom_button: Button = %ZoomBtn
@onready var pick_up_button: Button = %PickUpBtn
@onready var use_button: Button = %UseBtn
@onready var animation_player: AnimationPlayer = %Animations
@onready var area: Area2D = %AreaDetect

@onready var dot_icon_path: String = "res://ui/icons/dot.png"
@onready var dot_outline_icon_path: String = "res://ui/icons/dot_open.png"

@onready var playback_button: Button = %GameUI/PlaybackButton
@onready var main_scene: Node2D = $"/root/MainScene"

@warning_ignore("unused_signal")
signal dialogue_active(is_active: bool)

var wheel_open = false
var mouse_inside_area = false
var game_paused = false

func _ready() -> void:
	# Connect the dot button to the _on_dot_pressed function
	dot.connect("pressed", Callable(self, "_on_dot_pressed"))
	connect("gui_input", Callable(self, "_on_gui_input"))

	area.mouse_entered.connect(_on_enter_area.bind(true))
	area.mouse_exited.connect(_on_enter_area.bind(false))

	if playback_button:
		playback_button.connect("paused", Callable(self, "on_game_paused"))

	animation_player.connect("animation_finished", Callable(self, "show_buttons"))

	# Hovers
	dot.mouse_entered.connect(_on_button_hover.bind(dot))
	dot.mouse_exited.connect(_on_button_exit.bind(dot))
	if choices & 0x01:
		inspect_button.pressed.connect(on_inspect)
		inspect_button.mouse_entered.connect(_on_button_hover.bind(inspect_button))
		inspect_button.mouse_exited.connect(_on_button_exit.bind(inspect_button))
	if choices & 0x02:
		zoom_button.pressed.connect(on_zoom)
		zoom_button.mouse_entered.connect(_on_button_hover.bind(zoom_button))
		zoom_button.mouse_exited.connect(_on_button_exit.bind(zoom_button))
	if choices & 0x04:
		pick_up_button.mouse_entered.connect(_on_button_hover.bind(pick_up_button))
		pick_up_button.mouse_exited.connect(_on_button_exit.bind(pick_up_button))
	if choices & 0x08:
		use_button.mouse_entered.connect(_on_button_hover.bind(use_button))
		use_button.mouse_exited.connect(_on_button_exit.bind(use_button))

func _process(_delta: float) -> void:
	if game_paused and enable_on_scene:
		self.show()
	else:
		self.hide()

func _on_dot_pressed() -> void:
	if not wheel_open:
		InteractionManager.set_active_menu(self) # Set this menu as the active one
		show_choices()
	else:
		hide_choices()

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
		if choices & 0x01:
			inspect_button.show()
		if choices & 0x02:
			zoom_button.show()
		if choices & 0x04:
			pick_up_button.show()
		if choices & 0x08:
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

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if not mouse_inside_area:
				hide_choices()

func on_game_paused(state: bool) -> void:
	game_paused = state
	if state and enable_on_scene:
		self.show()
	else:
		self.hide()

func click_inside_menu() -> bool:
	print("Mouse inside area: ", mouse_inside_area)
	return mouse_inside_area

func click_in_buttons(pos: Vector2) -> bool:
	var check = inspect_button.get_global_rect().has_point(pos) or \
	zoom_button.get_global_rect().has_point(pos) or \
	pick_up_button.get_global_rect().has_point(pos) or \
	use_button.get_global_rect().has_point(pos)
	print("Check: ", check)
	return check

func _on_enter_area(mouse_inside: bool) -> void:
	if wheel_open and mouse_inside:
		mouse_inside_area = true
	else:
		mouse_inside_area = false

	print("Mouse inside area: ", mouse_inside_area)

func update_choices(new_choices: int) -> void:
	# Allows to change the choices from the outside
	choices = new_choices

func on_inspect() -> void:
	hide_choices()
	inspect_button.show_interaction_dialogue(inspect_dialogue)

func on_zoom() -> void:
	# For now, only show the object texture
	hide_choices()
	var document_wide = get_node("/root/MainScene/UI/DocumentWide")
	document_wide.show_object(zoom_object_path)
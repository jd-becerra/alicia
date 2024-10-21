extends Control
# This menu has a dot that scales up if clicked, showing the available 
# interaction choices for a given object.

# 4 available interaction choices: Inspect, Zoom, Pick Up, Use
enum InteractionChoice {
	INSPECT,
	ZOOM,
	PICK_UP,
	USE
}
@export var interaction_choices: Array = [InteractionChoice.INSPECT, InteractionChoice.ZOOM, InteractionChoice.PICK_UP, InteractionChoice.USE]

# The dot that scales up when clicked
@onready var dot: Button = %OpenWheelBtn
# The interaction choice buttons
@onready var inspect_button: Button = %InspectBtn
@onready var zoom_button: Button = %ZoomBtn
@onready var pick_up_button: Button = %PickUpBtn
@onready var use_button: Button = %UseBtn
@onready var animation_player: AnimationPlayer = %Animations

@onready var dot_icon_path: String = "res://ui/icons/dot.png"
@onready var dot_outline_icon_path: String = "res://ui/icons/interaction_choices_dot.png"

@onready var area: Area2D = %AreaDetect
@onready var playback_button: Button = $"/root/MainScene/UI/Menu/PlaybackButton"

var wheel_open = false

func _ready() -> void:
	# Connect the dot button to the _on_dot_pressed function
	dot.connect("pressed", Callable(self, "_on_dot_pressed"))
	area.connect("mouse_entered", Callable(self, "_on_dot_hover"))
	area.connect("mouse_exited", Callable(self, "hide_choices"))
	# Connect the interaction choice buttons to their respective functions
	inspect_button.connect("pressed", Callable(self, "_on_inspect_pressed"))
	zoom_button.connect("pressed", Callable(self, "_on_zoom_pressed"))
	pick_up_button.connect("pressed", Callable(self, "_on_pick_up_pressed"))
	use_button.connect("pressed", Callable(self, "_on_use_pressed"))

	playback_button.connect("paused", Callable(self, "on_game_paused"))

	# Hide the interaction choice buttons
	hide_choices()

func _on_dot_pressed() -> void:
	# Play the animation to scale up the dot
	if not wheel_open:
		show_choices()

func _on_inspect_pressed() -> void:
	# Hide the interaction choice buttons
	hide_choices()
	print("Inspect")
	# Emit the signal to notify the object that the Inspect choice was selected
	# emit_signal("interaction_choice_selected", InteractionChoice.INSPECT)

func _on_zoom_pressed() -> void:
	# Hide the interaction choice buttons
	hide_choices()
	print("Zoom")
	# Emit the signal to notify the object that the Zoom choice was selected
	# emit_signal("interaction_choice_selected", InteractionChoice.ZOOM)

func _on_pick_up_pressed() -> void:
	# Hide the interaction choice buttons
	hide_choices()
	print("Pick Up")
	# Emit the signal to notify the object that the Pick Up choice was selected
	# emit_signal("interaction_choice_selected", InteractionChoice.PICK_UP)

func _on_use_pressed() -> void:
	# Hide the interaction choice buttons
	hide_choices()
	print("Use")
	# Emit the signal to notify the object that the Use choice was selected
	# emit_signal("interaction_choice_selected", InteractionChoice.USE)

func show_choices() -> void:
	dot.icon = load(dot_outline_icon_path)
	animation_player.play("open_wheel")
	wheel_open = true

func hide_choices() -> void:
	print("hide")
	# Stop the animation
	animation_player.stop()

	# Hide the interaction choice buttons
	inspect_button.hide()
	zoom_button.hide()
	pick_up_button.hide()
	use_button.hide()

	dot.icon = load(dot_icon_path)
	dot.scale = Vector2(1, 1)

	wheel_open = false

func _on_dot_hover() -> void:
	if not wheel_open:
		dot.scale = Vector2(1.1, 1.1)

func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		print("input")
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not self.get_global_rect().has_point(event.global_position):
			print("hide")
			hide_choices()

func on_game_paused(state: bool) -> void:
	if state:
		self.show()
	else:
		self.hide()
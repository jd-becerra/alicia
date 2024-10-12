# This script triguers a DialogueManager dialogue whenever a "dialogue_starter" character enters the area.
# The dialogue is triggered ONLY if the game is not paused (we get a custom signal for this).

extends Area2D

@export var dialog: DialogueResource
@export var enable_dialogue: bool = false

@onready var playback_button: Button = $"/root/MainScene/CanvasLayer/Menu/PlaybackButton"

var is_paused: bool = false
var dialogue_was_triggered: bool = false
var in_dialogue_area: bool = false

@warning_ignore("unused_signal")
signal dialogue_triggered(is_active: bool)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	playback_button.connect("paused", Callable(self, "_on_game_paused"))

func _process(_delta: float) -> void:
	if in_dialogue_area and enable_dialogue and not dialogue_was_triggered:
		start_dialogue()
		dialogue_was_triggered = true

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("dialogue_starter") and not is_paused:
		print("Entered dialogue area")
		in_dialogue_area = true

func start_dialogue():
	DialogueManager.show_example_dialogue_balloon(dialog, "start")
	# Stop the animation player by sending a signal to set_speed_scale(0)
	emit_signal("dialogue_triggered", true)
	if not DialogueManager.dialogue_ended.is_connected(Callable(self, "_on_dialogue_finished")):
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_game_paused(paused: bool) -> void:
	is_paused = paused

func _on_dialogue_finished(_resource: DialogueResource) -> void:
	emit_signal("dialogue_triggered", false)

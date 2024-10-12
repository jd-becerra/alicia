# This script triguers a DialogueManager dialogue whenever a "dialogue_starter" character enters the area.
# The dialogue is triggered ONLY if the game is not paused (we get a custom signal for this).

extends Area2D

@export var dialog: DialogueResource

@onready var playback_button: Button = $"/root/MainScene/CanvasLayer/Menu/PlaybackButton"

var is_paused: bool = false

@warning_ignore("unused_signal")
signal dialogue_triggered(is_active: bool)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	playback_button.connect("paused", Callable(self, "_on_game_paused"))

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("dialogue_starter") and not is_paused:
		print("Dialogue started")
		DialogueManager.show_example_dialogue_balloon(dialog, "start")
		# Pause the animation player by sending a signal
		emit_signal("dialogue_triggered", true)
		if not DialogueManager.dialogue_ended.is_connected(Callable(self, "_on_dialogue_finished")):
			DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_game_paused(paused: bool) -> void:
	is_paused = paused

func _on_dialogue_finished(_resource: DialogueResource) -> void:
	emit_signal("dialogue_triggered", false)

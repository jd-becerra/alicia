extends Node
class_name DialogueController
# Handles only the dialogue part of the interaction choices

@onready var dialogue_balloon_path = "res://dialogue/balloon.tscn"
@onready var game_gui: Control = get_tree().get_root().get_node("MainScene").get_node("%GameUI")

var dialogue: DialogueResource
var enable_dialogue: bool = true
var is_paused: bool = false
var dialogue_was_triggered: bool = false
var scene: PackedScene
var start_point = ""

@warning_ignore("unused_signal")
signal dialogue_triggered(is_active: bool)

func start_dialogue(starting_point: String) -> void:
    start_point = starting_point

    game_gui.hide()

    show_dialogue(starting_point)
    emit_signal("dialogue_triggered", true)
    if not DialogueManager.dialogue_ended.is_connected(Callable(self, "_on_dialogue_finished")):
        DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func show_dialogue(starting_point: String) -> Node:
    var balloon = load(dialogue_balloon_path).instantiate()
    # get_current_scene().add_child(balloon)
    get_tree().get_root().add_child(balloon)
    balloon.start(dialogue, starting_point, [])
    return balloon

func _on_dialogue_finished(_resource: DialogueResource) -> void:
    emit_signal("dialogue_triggered", false)
    if start_point != "Zoom" and \
            start_point != "Correct_Sequence" and \
            start_point != "final":
        game_gui.show()
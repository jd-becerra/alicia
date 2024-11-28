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

var no_show_gui = [
    "Zoom",
    "Correct_Sequence",
    "Incorrect_Sequence",
    "final",
]

@warning_ignore("unused_signal")
signal dialogue_triggered(is_active: bool)

func start_dialogue(starting_point: String) -> void:
    game_gui.hide()

    show_dialogue(starting_point)
    emit_signal("dialogue_triggered", true)

    # Disconnect the signal to avoid multiple connections
    if DialogueManager.dialogue_ended.is_connected(_on_dialogue_finished):
        DialogueManager.dialogue_ended.disconnect(_on_dialogue_finished)        

    DialogueManager.dialogue_ended.connect(_on_dialogue_finished.bind(starting_point))

func show_dialogue(starting_point: String) -> Node:
    var balloon = load(dialogue_balloon_path).instantiate()
    get_tree().get_root().add_child(balloon)
    balloon.start(dialogue, starting_point, [])
    return balloon

func _on_dialogue_finished(_resource: DialogueResource, start_point) -> void:
    print("Start point: ", start_point)
    if start_point not in no_show_gui and not InteractionManager.animation_playing_first_time:
        print("CAN SHOW GUI")
        print("     Showing game gui for: ", start_point, " animation_playing_first_time: ", InteractionManager.animation_playing_first_time)
        show_gui()
    else:
        print("CAN'T SHOW GUI")
        print("     Not showing game gui for: ", start_point, " animation_playing_first_time: ", InteractionManager.animation_playing_first_time)
        game_gui.hide()
    # Reset start point because fuck Godot (it seems to keep the start_point even if dialogue ended) 
    start_point = ""
    emit_signal("dialogue_triggered", false)

    DialogueManager.dialogue_ended.disconnect(_on_dialogue_finished)

func show_gui():
    print("     SHOWING THE GUI")
    game_gui.show()
    game_gui.get_node("%Bottom").show()
    game_gui.get_node("%PlaybackButton").show()
    game_gui.get_node("%ProgressBar").show()
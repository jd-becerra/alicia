# This script triguers a DialogueManager dialogue whenever a "dialogue_starter" character enters the area.
# The dialogue is triggered ONLY if the game is not paused (we get a custom signal for this).

extends Area2D

@export var dialog: DialogueResource

@export var enable_dialogue: bool = true  
@export var dialogue_name: String = ""
@export var force_start_dialogue: bool = false

@onready var is_dragging: bool = false  # If the player is dragging the progress bar
@onready var controller: Node = $"/root/MainScene"
@onready var game_gui: Control = %GameUI
@onready var playback_button: Button = game_gui.get_node("PlaybackButton")
@onready var dialogue_balloon_path = "res://dialogue/balloon.tscn"
@onready var anim_player: AnimationPlayer = $"/root/MainScene/AnimationPlayer"

var is_paused: bool = false  # If game is in paused state
var dialogue_was_triggered: bool = false  # If dialogue started
var in_dialogue_area: bool = false  # If character is in the dialogue area (doesn't activate dialogue necessarily)

var last_force_time: float = 0
var dialogue_was_forced: bool = false

@warning_ignore("unused_signal")
signal dialogue_triggered(is_active: bool)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	controller.connect("enable_dialogue", Callable(self, "_on_enable_dialogue"))
	controller.connect("dragging_enabled", Callable(self, "_on_dragging"))
	playback_button.connect("paused", Callable(self, "_on_game_paused"))

func _process(_delta: float) -> void:
	# If enable_dialogue, dialogue CAN be triggered, if: 
	# - the player is in the area
	# - the game is not paused 
	# - the dialogue was not triggered yet
	# - the player is not dragging the progress bar

	if enable_dialogue and not dialogue_was_triggered and not is_dragging and dialogue_name != "":
		start_dialogue()
		dialogue_was_triggered = true

	if not is_dragging and not enable_dialogue:
		dialogue_was_triggered = false

	# If previous conditions are not met, but the dialogue should be triggered, force it
	if force_start_dialogue:
		start_dialogue()
		dialogue_was_forced = true
		force_start_dialogue = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("dialogue_starter") and not is_paused:
		in_dialogue_area = true

func start_dialogue():
	if (is_paused or not enable_dialogue or is_dragging) and not force_start_dialogue:
		return

	game_gui.hide()

	show_dialogue()
	# Stop the animation player by sending a signal to set_speed_scale(0)
	emit_signal("dialogue_triggered", true)

	if force_start_dialogue:
		last_force_time = anim_player.current_animation_position
		anim_player.set_speed_scale(0)
	
	if not DialogueManager.dialogue_ended.is_connected(Callable(self, "_on_dialogue_finished")):
		DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

func _on_game_paused(paused: bool) -> void:
	is_paused = paused

func _on_dialogue_finished(_resource: DialogueResource) -> void:
	if dialogue_was_forced:
		anim_player.set_speed_scale(1)
		dialogue_was_forced = false
	else:
		game_gui.show()
	emit_signal("dialogue_triggered", false)
	

func _on_enable_dialogue(is_active: bool) -> void:
	enable_dialogue = is_active

func _on_dragging(dragging_state: bool) -> void:
	is_dragging = dragging_state

func show_dialogue():
	var balloon = load(dialogue_balloon_path).instantiate()
	get_current_scene().add_child(balloon)
	balloon.start(dialog, dialogue_name, [])
	return balloon

func get_current_scene() -> Node:
	var current_scene: Node = get_tree().current_scene
	if current_scene == null:
		current_scene = get_tree().root.get_child(get_tree().root.get_child_count() - 1)
	return current_scene
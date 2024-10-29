extends Node2D
class_name IndividualAnimationController

@export var animation_name = ""

var is_paused: bool = false
var is_forward: bool = false
var dialogue_triggered: bool = false

@onready var main_scene: Node = get_tree().get_root().get_node("MainScene")
@onready var playback_button: Button = %GameUI/PlaybackButton
@onready var anim: AnimationPlayer = self.get_node("AnimationPlayer")
@onready var interaction_manager: Node = get_node("/root/MainScene/InteractionManager")

# Virtual functions that can be overridden in child scripts
func _ready():
	# Optional connection of signals, child classes can extend this logic
	if playback_button:
		playback_button.connect("paused", Callable(self, "_on_paused"))
	if main_scene:
		main_scene.connect("animation_forward", Callable(self, "_on_change_animation_direction"))

	for node in main_scene.get_tree().get_nodes_in_group("dialogue_trigger_area"):
		node.connect("dialogue_triggered", Callable(self, "_on_dialogue_triggered"))

# Child classes can override _physics_process if they want to modify animation logic
func _physics_process(_delta):
	if not dialogue_triggered and not interaction_manager.current_animation_player:
		if anim and animation_name != anim.current_animation and animation_name != "":
			anim.play(animation_name)
	
	if interaction_manager.current_animation_player:
		print(interaction_manager.current_animation_player.current_animation)

# Functions that can be reused or overridden
func _on_paused(new_paused_state: bool):
	self.is_paused = new_paused_state
	
	if is_paused:
		anim.set_speed_scale(0)
	else:
		anim.set_speed_scale(1)

func _on_dialogue_triggered(state: bool):
	self.dialogue_triggered = state
	# anim.stop()

func _on_change_animation_direction(state: bool):
	self.is_forward = state

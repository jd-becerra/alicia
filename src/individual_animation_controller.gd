extends Node2D

@export var animation_name = ""

var is_paused: bool = false
var is_forward: bool = false

@onready var main_scene: Node = get_tree().get_root().get_node("MainScene")
@onready var playback_button: Button = main_scene.get_node("CanvasLayer/Menu/PlaybackButton")
@onready var anim: AnimationPlayer = self.get_node("AnimationPlayer")

func _ready():
	if playback_button:
		playback_button.connect("paused", Callable(self, "_on_paused"))
	if main_scene:
		main_scene.connect("animation_forward", Callable(self, "_on_change_animation_direction"))

func _physics_process(_delta):
	if anim and animation_name != anim.current_animation and animation_name != "":
		anim.play(animation_name)

func _on_paused(new_paused_state: bool):
	self.is_paused = new_paused_state
	if is_paused:
		anim.set_speed_scale(0)
	else:
		anim.set_speed_scale(1)
	#print("Paused: ", is_paused)

func _on_change_animation_direction(state: bool):
	self.is_forward = state
	#print("Forward: ", is_forward)

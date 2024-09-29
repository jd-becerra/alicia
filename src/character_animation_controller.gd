extends CharacterBody2D
@export var player: AnimationPlayer
@export var animation_name = ""

func _ready():
	pass

func _physics_process(_delta):
	if player and animation_name and animation_name != player.current_animation and animation_name != "":
		player.play(animation_name)

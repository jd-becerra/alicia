extends Node

# EXPORTS AND IMPORTS
@export var game_paused = false

@onready var main_scene: Node2D = get_node("/root/MainScene")
@onready var player: Node2D = main_scene.get_node("%Player")

# This node saves all the states of objects in the game, so that they can access a global node

var piano_open = false
var skip_dialogue = false
var puzzle_solved = false
var piano_has_sheet_music = false
var piano_menu_open = false

func _process(_delta):
    if game_paused:
        set_game_as_paused()

func set_game_as_paused():
    pass        
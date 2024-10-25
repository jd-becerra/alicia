extends Node2D

@export var animation: AnimationPlayer
@export var animation_name: String = ""
@export var player_animation_character: CharacterBody2D
@export var player_movement_character: CharacterBody2D
@export var animation_camera: Camera2D
@export var movement_camera: Camera2D
@export var dialogue_indicator_times: Array[float]

@onready var main_scene: Node2D = get_node("/root/MainScene")
@onready var menu: Control = $UI/Menu
@onready var inventory_ui: Control = $UI/Menu/InventoryUI
@onready var playback_button: Button = menu.get_node("PlaybackButton")
@onready var progress_bar: ProgressBar = menu.get_node("ProgressBar")
@onready var inventory: PanelContainer = menu.get_node("InventoryUI/Inventory")

@onready var dialogue_indicator: PackedScene = preload("res://ui/dialogue_indicator.tscn")

var is_dragging: bool = false
var last_time = 0
var is_paused: bool = false
var tolerance: float = 0.01  # Tolerance for animation end comparison
var animation_finished = false
var is_dialogue_triggered = false
var animation_played_first_time = true

# Signals used in other scripts
@warning_ignore("unused_signal") 
signal animation_forward(is_forward: bool)
@warning_ignore("unused_signal")
signal enable_dialogue(is_active: bool)
@warning_ignore("unused_signal")
signal dragging_enabled(dragging_state: bool)

func _ready():
	# Make animation_name the current animation
	animation.play(animation_name)
	last_time = animation.current_animation_position

	# Ensure signal is connected only once
	playback_button.connect("paused", Callable(self, "_on_paused"))

	# Connect to the enable_dialogue signal with all DialogueTrigger nodes
	connect("enable_dialogue", Callable(self, "_on_enable_dialogue"))
	connect("dragging_enabled", Callable(self, "_on_dragging"))

	# add_dialogue_indicators()  # FEATURE TO BE DECIDED

	# Connect to the dialogue trigger signal with all DialogueTrigger nodes
	for node in main_scene.get_tree().get_nodes_in_group("dialogue_trigger_area"):
		node.connect("dialogue_triggered", Callable(self, "on_dialogue_triggered"))
	# Also connect all DialogueController Nodes from interaction menus
	for node in main_scene.get_tree().get_nodes_in_group("interaction_menu"):
		var dialogue_controller = node.get_node("DialogueController")
		dialogue_controller.connect("dialogue_triggered", Callable(self, "on_dialogue_triggered"))

func _process(delta):
	# THIS FEATURE WILL BE IMPLEMENTED IN THE FINAL BUILD
	# Enable progress bar only after animation was played for the first time
	# if animation_played_first_time and animation_finished:
		# playback_button.visible = true
		# progress_bar.visible = true
		# animation_played_first_time = false

	if not is_dragging and animation.is_playing() and not is_paused and not is_dialogue_triggered:
		animation.set_speed_scale(1)
		progress_bar.value = animation.current_animation_position / animation.get_current_animation_length() * 100

	# Seek with arrow keys (optional)
	if Input.is_action_pressed("ui_left"):
		animation.seek(animation.current_animation_position - delta, true)
	elif Input.is_action_pressed("ui_right"):
		animation.seek(animation.current_animation_position + delta, true)

	# Check if animation reaches the end using tolerance for floating point precision
	if animation.current_animation_position >= animation.get_current_animation_length() - tolerance:
		if not animation_finished:
			animation_finished = true
			playback_button.is_paused = true
			playback_button.emit_signal("paused", true)
	else:
		animation_finished = false

func _input(event):
	# Check if the mouse is pressed (for clicking) or if dragging the progress bar
	var dragging = event is InputEventMouseMotion and is_dragging
	var clicking = event is InputEventMouseButton and event.pressed
	if dragging or (clicking and progress_bar.get_global_rect().has_point(event.global_position)) and not is_dialogue_triggered:
		# Disable the dialogue trigger when dragging the progress bar
		if not is_dragging:
			is_dragging = true
			emit_signal("dragging_enabled", true)

		animation.set_speed_scale(0)

		var mouse_pos = event.global_position.x - progress_bar.get_global_rect().position.x
		var progress = clamp(mouse_pos / progress_bar.get_global_rect().size.x, 0, 1)
		progress_bar.value = progress * 100
		
		# Update the animation's position based on progress
		if not animation.is_playing():
			animation.play(animation_name)
		var new_time = progress * animation.get_current_animation_length()
		animation.seek(new_time, true)

		# Detect if animation is being played backwards or forwards
		if new_time != last_time:
			emit_signal("animation_forward", new_time > last_time)
			last_time = new_time

	# Detect when the mouse button is released, stop dragging
	if event is InputEventMouseButton and not event.pressed and is_dragging:
		is_dragging = false
		emit_signal("dragging_enabled", false)
		emit_signal("enable_dialogue", false)

func on_dialogue_triggered(is_active: bool):
	print("Dialogue triggered: ", is_active)
	is_dialogue_triggered = is_active

	if is_active:
		animation.set_speed_scale(0)


func _on_paused(state: bool):
	is_paused = state
	if is_paused:
		inventory_ui.can_show_inventory = true
		# Change uniform bool "activate" of shader material for every node in "grayscale" group
		for node in get_tree().get_nodes_in_group("grayscale"):
			# WARNING: the node has to have the shader material "gray_filter" attached to it
			node.material.set_shader_parameter("activate", true) 

		animation.set_speed_scale(0)

		# Activate movement_camera and deactivate animation_camera
		movement_camera.global_position = animation_camera.global_position

		var new_pos = Vector2.ZERO
		# The spawnable property of player_animation_character is set in the AnimationPlayer
		# This allows us to know if player_animation_character position is valid in the animation scene
		if player_animation_character.is_spawnable():
			new_pos = player_animation_character.global_position
		else:
			new_pos = Vector2(animation_camera.position.x, player_animation_character.global_position.y)

		animation_camera.enabled = false
		movement_camera.enabled = true

		var new_dir = player_animation_character.get_node("Sprite2D").flip_h
		player_movement_character.initialize(new_pos, new_dir)

		# player_animation_character.visible = false	

	else:
		inventory_ui.can_show_inventory = false

		# Change uniform bool "activate" of shader material for every node in "grayscale" group
		for node in get_tree().get_nodes_in_group("grayscale"):
			# WARNING: the node has to have the shader material "gray_filter" attached to it
			node.material.set_shader_parameter("activate", false)

		# If the animation has reached the end, reset it before playing it again
		if animation.current_animation_position >= animation.get_current_animation_length() - tolerance:
			animation.play(animation_name)
		if animation_finished:
			# If animation was finished, reset it before playing again if button is pressed in this state
			animation_finished = false
			animation.seek(0, true)
		animation.set_speed_scale(1)

		# Activate animation_camera and deactivate movement_camera
		animation_camera.enabled = true
		movement_camera.enabled = false

		# Remove player_movement_character and add player_animation_character
		
		player_movement_character.hide_player()
		# player_animation_character.visible = true

func add_dialogue_indicators():
	# Convert the time of each item to a percentage of the animation length
	var animation_length = animation.get_current_animation_length()

	for time in dialogue_indicator_times:
		var indicator = dialogue_indicator.instantiate()
		
		# Calculate the percentage of the animation
		var time_percentage = time / animation_length
		
		# Calculate the position relative to the progress bar
		var indicator_x = progress_bar.size.x * time_percentage
		
		# Create a container for proper positioning
		var container = Control.new()
		container.set_anchors_preset(Control.PRESET_FULL_RECT)
		
		# Set the indicator's position relative to the progress bar
		indicator.position = Vector2(indicator_x, 0)
		
		# Add the indicator to the progress bar directly
		progress_bar.add_child(container)
		container.add_child(indicator)
extends Node2D

@export var animation: AnimationPlayer
@export var animation_name: String = ""
@export var player_animation_character: CharacterBody2D
@export var player_movement_character: CharacterBody2D

@onready var main_scene: Node2D = get_node("/root/MainScene")
@onready var menu: Control = $Menu
@onready var playback_button: Button = menu.get_node("PlaybackButton")
@onready var progress_bar: ProgressBar = menu.get_node("ProgressBar")
@onready var player_movement
var is_dragging: bool = false
var last_time = 0
var is_paused: bool = false
var tolerance: float = 0.01  # Tolerance for animation end comparison
var animation_finished = false

# Signals used in other scripts
@warning_ignore("unused_signal") 
signal animation_forward(is_forward: bool)

func _ready():
	# Make animation_name the current animation
	animation.play(animation_name)
	last_time = animation.current_animation_position

	# Ensure signal is connected only once
	playback_button.connect("paused", Callable(self, "_on_paused"))

func _process(delta):
	if not is_dragging and animation.is_playing():
		progress_bar.value = animation.current_animation_position / animation.get_current_animation_length() * 100

	# Seek with arrow keys (optional)
	if Input.is_action_pressed("ui_left"):
		animation.seek(animation.current_animation_position - delta, true)
	elif Input.is_action_pressed("ui_right"):
		animation.seek(animation.current_animation_position + delta, true)

	# Check if animation reaches the end using tolerance for floating point precision
	if animation.current_animation_position >= animation.get_current_animation_length() - tolerance:
		animation_finished = true
		playback_button.is_paused = true
		playback_button.emit_signal("paused", true)

func _input(event):
	# Check if the mouse is pressed (for clicking) or if dragging the progress bar
	var dragging = event is InputEventMouseMotion and is_dragging
	var clicking = event is InputEventMouseButton and event.pressed
	if dragging or clicking:
		if progress_bar.get_global_rect().has_point(event.global_position):
			is_dragging = true
			var mouse_pos = event.global_position.x - progress_bar.get_global_rect().position.x
			var progress = clamp(mouse_pos / progress_bar.get_global_rect().size.x, 0, 1)
			progress_bar.value = progress * 100 
			
			# Update the animation's position based on progress
			if not animation.is_playing():
				animation.play(animation_name)
			var new_time = progress * animation.get_current_animation_length()
			animation.seek(new_time, true)

			# Detect if animation is being played backwards or forwards
			emit_signal("animation_forward", new_time > last_time)
			last_time = new_time
	
	# Detect when the mouse button is released, stop dragging
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false

func _on_paused(state: bool):
	is_paused = state
	if is_paused:
		animation.set_speed_scale(0)
		# Remove player_animation_character and add player_movement_character
		# Don't remove player_animation_character, just hide it
		player_animation_character.visible = false		
		player_movement_character.visible = true
		player_movement_character.initialize_position(player_animation_character.global_position)
		player_movement_character.update_sprite_direction(player_animation_character.get_node("Sprite2D").flip_h)
		player_movement_character._on_game_paused(true)
	else:
		# If the animation has reached the end, reset it before playing it again
		if animation.current_animation_position >= animation.get_current_animation_length() - tolerance:
			animation.play(animation_name)
		if animation_finished:
			# If animation was finished, reset it before playing again if button is pressed in this state
			animation_finished = false
			animation.seek(0, true)
		animation.set_speed_scale(1)

		# Remove player_movement_character and add player_animation_character
		print("Player cannot move")
		player_movement_character._on_game_paused(false)
		player_movement_character.visible = false
		player_animation_character.visible = true

	# print("Paused: ", is_paused)

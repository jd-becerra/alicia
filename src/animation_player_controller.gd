extends Node2D

@export var animation: AnimationPlayer
@export var animation_name: String = ""

@onready var menu: Control = $Menu
@onready var playback_button: Button = menu.get_node("PlaybackButton")
@onready var progress_bar: ProgressBar = menu.get_node("ProgressBar")
var is_dragging: bool = false
var last_time = 0
var is_paused: bool = false
var tolerance: float = 0.01  # Tolerance for animation end comparison

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
		playback_button.is_paused = true
		playback_button.emit_signal("paused", true)

func _input(event):
	# Check if the mouse is pressed and dragging the progress bar
	if event is InputEventMouseButton and event.pressed:
		if progress_bar.get_global_rect().has_point(event.global_position):
			is_dragging = true
	
	if event is InputEventMouseMotion and is_dragging:
		# Convert the mouse position into a progress bar value
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
	
	# Detect when the mouse is released, even outside the bounds of the progress bar
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false

func _on_paused(state: bool):
	is_paused = state
	if is_paused:
		animation.set_speed_scale(0)
	else:
		# If the animation has reached the end, reset it before playing again
		if animation.current_animation_position >= animation.get_current_animation_length() - tolerance:
			animation.play(animation_name)
		animation.set_speed_scale(1)
	print("Paused: ", is_paused)

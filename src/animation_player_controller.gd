extends Node2D

@export var animation: AnimationPlayer
@export var animation_name: String = ""

@onready var menu: Control = $Menu
@onready var progress_bar: ProgressBar = menu.get_node("ProgressBar")
var is_dragging: bool = false

func _ready():
	# Make animation_name the current animation
	animation.play(animation_name)
	animation.stop(false) # Pause the animation but don't reset state

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if not is_dragging and animation.is_playing():
		progress_bar.value = animation.current_animation_position / animation.get_current_animation_length() * 100
	
	# Seek with arrow keys (optional)
	if Input.is_action_pressed("ui_left"):
		animation.seek(animation.current_animation_position - delta, true)
	elif Input.is_action_pressed("ui_right"):
		animation.seek(animation.current_animation_position + delta, true)

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
		var new_time = progress * animation.get_current_animation_length()
		animation.seek(new_time, true)
	
	# Detect when the mouse is released to stop dragging
	if event is InputEventMouseButton and not event.pressed:
		is_dragging = false

extends CharacterBody2D

@export var speed: float = 5000.0
@export var stop_distance: float = 5.0
@export var move_threshold: float = 10.0
@export var tolerance: float = 1.0  # Tolerance for small position changes
@export var double_click_time: float = 0.5
@export var double_speed_multiplier: float = 2.0
@export var double_click_distance_threshold: float = 100.0

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var playback_button: Button = $"/root/MainScene/CanvasLayer/Menu/PlaybackButton"
@onready var progress_bar: ProgressBar = $"/root/MainScene/CanvasLayer/Menu/ProgressBar"


var game_paused = false
var is_moving = false
var last_click_time = 0.0
var is_double_speed = false
var target_position = Vector2.ZERO
var last_position = Vector2.ZERO
var last_click_position = Vector2.ZERO
var clicked = false
var is_dragging = false
var first_click = false  # To detect double-click

func _ready():
	# target_position = global_position
	# last_position = global_position
	playback_button.connect("paused", Callable(self, "_on_game_paused"))

func _input(event):
	if not game_paused or not self.visible:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if not click_inside_menu(event.global_position):
				handle_click(event.global_position)
		else:
			clicked = false
			is_dragging = false

	if clicked or is_dragging:
		update_target_position(get_global_mouse_position())

func handle_click(click_position: Vector2):
	clicked = true
	is_dragging = true
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if click_position.distance_to(last_click_position) < double_click_distance_threshold:
		is_double_speed = true
		print("Double speed activated")
	else:
		is_double_speed = false
	
	last_click_time = current_time
	last_click_position = click_position
	update_target_position(click_position)

func update_target_position(new_position: Vector2):
	new_position.y = global_position.y  # Restrict to x-axis
	if new_position.distance_to(global_position) > move_threshold:
		target_position = new_position
		is_moving = true

func _physics_process(delta):
	# Player can only move when the game is paused
	if not game_paused or not self.visible:
		return

	if not is_moving:
		handle_idle_state()
		return

	# Restrict movement to x-axis only
	var direction = Vector2(sign(target_position.x - global_position.x), 0)
	var current_speed = speed * (double_speed_multiplier if is_double_speed else 1.0)
	velocity = direction * current_speed * delta

	var distance_to_target = abs(target_position.x - global_position.x)
	if distance_to_target > stop_distance:
		move_and_slide()

		update_sprite_direction(direction.x < 0)
		animation.play("Walk")

		# Check if the player is stuck
		if abs(global_position.x - last_position.x) < tolerance:
			is_moving = false
			velocity = Vector2.ZERO

		last_position = global_position  # Update last position
	else:
		is_moving = false
		velocity = Vector2.ZERO
		is_double_speed = false

func update_sprite_direction(flip: bool):
	sprite.flip_h = flip

func handle_idle_state():
	is_moving = false
	velocity = Vector2.ZERO
	animation.play("Idle")

func _on_game_paused(state: bool):
	game_paused = state
	self.visible = not game_paused
	if game_paused:
		is_moving = false
		velocity = Vector2.ZERO

	print("Game paused:", game_paused)

func click_inside_menu(pos: Vector2) -> bool:
	return progress_bar.get_global_rect().has_point(pos) or playback_button.get_global_rect().has_point(pos)

func initialize(pos: Vector2, flip: bool):
	_on_game_paused(true)
	last_click_time = 0.0
	is_double_speed = false
	last_click_position = Vector2.ZERO

	global_position = pos
	target_position = global_position
	last_position = Vector2.ZERO


	update_sprite_direction(flip)
	
	self.visible = true

	print("Player initialized at:", global_position)

func hide_player():
	_on_game_paused(false)
	target_position = Vector2.ZERO
	last_position = Vector2.ZERO
	is_moving = false
	is_double_speed = false
	velocity = Vector2.ZERO
	update_sprite_direction(false)
	self.visible = false

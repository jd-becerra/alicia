extends CharacterBody2D

@export var speed: float = 5000.0
@export var stop_distance: float = 5.0
@export var move_threshold: float = 10.0
@export var tolerance: float = 1.0  # Tolerance for small position changes
@export var double_click_time: float = 0.5
@export var double_speed_multiplier: float = 2.0
@export var restricted: bool = false  # Unlike game_paused, this can be used by other scripts and AnimationPlayers

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var playback_button: Button = $"/root/MainScene/Menu/PlaybackButton"
@onready var progress_bar: ProgressBar = $"/root/MainScene/Menu/ProgressBar"


var game_paused = false
var is_moving = false
var last_click_time = 0.0
var is_double_speed = false
var target_position = Vector2.ZERO
var last_position = Vector2.ZERO
var last_click_position = Vector2.ZERO

func _ready():
	# target_position = global_position
	# last_position = global_position
	playback_button.connect("paused", Callable(self, "_on_game_paused"))

func _input(event):
	if not game_paused or not self.visible:
		# If animation is paused
		return

	if restricted:
		# If the player is restricted from moving in a certain part of the animation
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and not click_inside_menu(event.global_position):
		var current_time = Time.get_ticks_msec() / 1000.0
		var new_target_position = get_global_mouse_position()

		# Restrict target position to x-axis (from center of the screen)
		new_target_position.y = global_position.y

		if new_target_position.distance_to(global_position) > move_threshold:
			if current_time - last_click_time < double_click_time and new_target_position.distance_to(last_click_position) < move_threshold:
				is_double_speed = true
			else:
				is_double_speed = false
			
			target_position = new_target_position
			is_moving = true
			last_click_time = current_time
			last_click_position = new_target_position

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
		# global_position += velocity

		update_sprite_direction(direction.x < 0)
		animation.play("Walk")

		# Check if the player is stuck
		if abs(global_position.x - last_position.x) < tolerance:
			is_moving = false
			velocity = Vector2.ZERO
		
		last_position = global_position # Update last position
	
	else:
		is_moving = false
		velocity = Vector2.ZERO
		is_double_speed = false

func update_sprite_direction(flip: bool):
	sprite.flip_h = flip

func handle_idle_state():
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

func clear():
	_on_game_paused(false)
	target_position = Vector2.ZERO
	last_position = Vector2.ZERO
	is_moving = false
	is_double_speed = false
	velocity = Vector2.ZERO
	update_sprite_direction(false)
	self.visible = false
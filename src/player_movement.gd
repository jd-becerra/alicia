extends CharacterBody2D

@export_category("Movement")
@export var speed: float = 5000.0
@export var stop_distance: float = 5.0
@export var move_threshold: float = 10.0
@export var tolerance: float = 1.0  # Tolerance for small position changes
@export var double_click_time: float = 0.5
@export var double_speed_multiplier: float = 2.0
@export var double_click_distance_threshold: float = 100.0
@export var camera: Camera2D
@export var camera_bounds: Vector2  = Vector2(100, 100)   # Only define left and right bounds
@export var camera_speed: float = 50.0

#@export_category("Inventory")
@onready var inventory_data: Inventory = Inventory.new()

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var game_ui: Control = %GameUI
@onready var playback_button: Button = game_ui.get_node("PlaybackButton")
@onready var progress_bar: ProgressBar = game_ui.get_node("ProgressBar")
@onready var gui_bottom: Panel = game_ui.get_node("Bottom")
@onready var gui_top: Panel = game_ui.get_node("Top")
@onready var toggle_inventory_btn: Button = game_ui.get_node("ToggleInventoryBtn")
@onready var inventory: PanelContainer = game_ui.get_node("Inventory")
@onready var main_scene: Node2D = $"/root/MainScene"

@onready var interaction_menus = get_tree().get_nodes_in_group("interaction_menu")

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
var is_dialogue_active = false
var initial_y_position: float
var clicked_interaction_button: bool = false

func _ready():
	# target_position = global_position
	# last_position = global_position
	playback_button.connect("paused", Callable(self, "_on_game_paused"))
	
	# Make sure the player is not moving when there is a dialogue triggered
	for interaction_menu in main_scene.get_tree().get_nodes_in_group("interaction_menu"):
		var dialogue_controller = interaction_menu.get_node("DialogueController")
		dialogue_controller.connect("dialogue_triggered", Callable(self, "on_dialogue_triggered"))

		# Since the interaction menus take unhandled_input, we need to connect to the signal to receive it as well
		interaction_menu.connect("unhandled_left_click_release", Callable(self, "on_unhandled_left_click_release"))
		interaction_menu.connect("clicked_interaction_button", Callable(self, "on_interaction_button_clicked"))

func _input(event):
	if not game_paused or not self.visible or click_interactive_menus() or is_dialogue_active:
		return

	# Move normally with ui_left and ui_right to left or right(for debugging)
	if Input.is_action_pressed("ui_left"):
		global_position.x -= move_threshold
		return
	elif Input.is_action_pressed("ui_right"):
		global_position.x += move_threshold
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

func on_interaction_button_clicked(is_clicked: bool):
	clicked_interaction_button = is_clicked

func handle_click(click_position: Vector2):
	clicked = true
	is_dragging = true
	var current_time = Time.get_ticks_msec() / 1000.0
	
	if click_position.distance_to(last_click_position) < double_click_distance_threshold:
		is_double_speed = true
	else:
		is_double_speed = false
	
	last_click_time = current_time
	last_click_position = click_position
	update_target_position(click_position)

func update_target_position(new_position: Vector2):
	new_position.y = initial_y_position
	if new_position.distance_to(global_position) > move_threshold:
		target_position = new_position
		is_moving = true

func _physics_process(delta):
	# Player can only move when the game is paused
	if not game_paused or not self.visible:
		return

	if not is_moving or is_dialogue_active or clicked_interaction_button:
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

		update_camera_position(delta)

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

func click_inside_menu(pos: Vector2) -> bool:
	return gui_bottom.get_global_rect().has_point(pos) or \
		gui_top.get_global_rect().has_point(pos) or \
		inventory.get_global_rect().has_point(pos) or \
		toggle_inventory_btn.get_global_rect().has_point(pos)
	
func initialize(pos: Vector2, flip: bool):
	_on_game_paused(true)
	last_click_time = 0.0
	is_double_speed = false
	last_click_position = Vector2.ZERO

	global_position = pos
	initial_y_position = pos.y
	target_position = global_position
	last_position = Vector2.ZERO

	update_sprite_direction(flip)
	
	self.visible = true

func hide_player():
	_on_game_paused(false)
	target_position = Vector2.ZERO
	last_position = Vector2.ZERO
	is_moving = false
	is_double_speed = false
	velocity = Vector2.ZERO
	update_sprite_direction(false)
	self.visible = false

func update_camera_position(delta):
	var screen_size = get_viewport_rect().size
	var camera_pos = camera.global_position
	var player_pos = global_position

	var left_camera_margin = camera_bounds.x
	var right_camera_margin = camera_bounds.y

	# Calculate the target camera position based on the player's position near the edges
	var target_camera_pos = camera_pos

	if player_pos.x < camera_pos.x - (screen_size.x / 2) + left_camera_margin:
		# Adjusting calculation for smoother left edge movement
		target_camera_pos.x = player_pos.x + (screen_size.x / 2) - left_camera_margin
	# Move the camera right when the player is near the right margin
	elif player_pos.x > camera_pos.x + (screen_size.x / 2) - right_camera_margin:
		target_camera_pos.x = player_pos.x - (screen_size.x / 2) + right_camera_margin

	# Smoothly move the camera towards the target position using linear interpolation (lerp)
	camera.position.x = lerp(camera.position.x, target_camera_pos.x, camera_speed * delta)

	# Update target click position based on camera movement for the player
	if clicked or is_dragging:
		update_target_position(get_global_mouse_position())

func click_interactive_menus() -> bool:
	for menu in interaction_menus:
		if menu.mouse_inside_area:
			return true
	return false

func on_dialogue_triggered(is_active: bool):
	is_dialogue_active = is_active

func on_unhandled_left_click_release(event: InputEvent, _item: Item) -> void:
	# Some nodes can take over the release click event
	# Make sure every time the mouse is released, the player stops moving
	# IMPORTANT: keep the double-click detection, though

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			# Only reset movement if it wasn't a double-click
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_click_time >= double_click_time:
				is_moving = false
				velocity = Vector2.ZERO
				is_double_speed = false
			
			clicked = false
			is_dragging = false
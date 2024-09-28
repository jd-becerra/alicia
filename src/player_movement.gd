extends CharacterBody2D

@export var speed: float = 5000.0
@export var stop_distance: float = 5.0
@export var move_threshold: float = 10.0
@export var tolerance: float = 1.0  # Tolerance for small position changes

@onready var animation = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var anchor = $Anchor

var target_position = Vector2()
var is_moving = false
var last_position = Vector2.ZERO

func _ready():
	target_position = anchor.global_position
	last_position = anchor.global_position

func _input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		var new_target_position = get_global_mouse_position()
		if new_target_position.distance_to(anchor.global_position) > move_threshold:
			target_position = new_target_position
			is_moving = true

func _physics_process(delta):
	if not is_moving:
		handle_idle_state()
		return
	
	var direction = (target_position - anchor.global_position).normalized()
	print(direction)
	velocity = direction * speed * delta
	
	var distance_to_target = anchor.global_position.distance_to(target_position)
	if distance_to_target > stop_distance:
		move_and_slide()
		update_sprite_direction(direction)
		animation.play("Walk")

		# Check if the player is stuck
		if last_position.distance_to(anchor.global_position) < tolerance:
			is_moving = false
			velocity = Vector2.ZERO
		last_position = anchor.global_position # Update last position
	else:
		is_moving = false
		velocity = Vector2.ZERO

func update_sprite_direction(direction):
	sprite.flip_h = direction.x < 0

func handle_idle_state():
	velocity = Vector2.ZERO
	animation.play("None")
extends Control

@onready var sprite_logo: AnimatedSprite2D = %Logo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite_logo.play("Dance")
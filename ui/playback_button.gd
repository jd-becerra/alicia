extends Button

@warning_ignore("unused_signal")
signal paused(is_paused: bool)

var is_paused: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_pressed() -> void:
	is_paused = !is_paused
	emit_signal("paused", is_paused)

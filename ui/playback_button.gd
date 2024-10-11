extends Button

@warning_ignore("unused_signal")
signal paused(is_paused: bool)

var is_paused: bool = false

func _on_pressed() -> void:
	print("Toggling pause")
	is_paused = !is_paused
	emit_signal("paused", is_paused)
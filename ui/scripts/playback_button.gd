extends Button

@warning_ignore("unused_signal")
signal paused(is_paused: bool)

@onready var pause_icon_paht: String = "res://ui/icons/pause.png"
@onready var play_icon_path: String = "res://ui/icons/play.png"

var is_paused: bool = false

func _on_pressed() -> void:
	is_paused = !is_paused
	emit_signal("paused", is_paused)

	if is_paused:
		icon = load(play_icon_path)
	else:
		icon = load(pause_icon_paht)
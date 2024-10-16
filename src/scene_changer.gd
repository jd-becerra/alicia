extends CanvasLayer

@warning_ignore("unused_signal")
signal scene_changed()

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var black_screen: Control = $Control/ColorRect

func transition_scene(path, delay = 0.5):
	# Fade out
	await get_tree().create_timer(delay).timeout
	animation_player.play("fade_out")
	# Wait for the animation to finish
	await animation_player.animation_length("fade_out")
	assert(get_tree().change_scene_to_packed(path) == OK)
	animation_player.play("fade_in")
	await animation_player.animation_length("fade_in")
	emit_signal("scene_changed")
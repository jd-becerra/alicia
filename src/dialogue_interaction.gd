extends Node

signal animation_playing(state: bool)
signal dialogue_animation_finished(state: bool)

func play_dialogue_animation(character: String, animation_name: String) -> void:
	var route = "/root/MainScene/Characters/" + character + "/AnimationPlayer"
	play_anim(route, animation_name)

func play_object_animation(object: String, animation_name: String) -> void:
	var route = "/root/MainScene/Objects/" + object + "/AnimationPlayer"
	play_anim(route, animation_name)

func play_anim(route: String, animation_name: String) -> void:
	var anim_player: AnimationPlayer = get_node(route)
	anim_player.current_animation = animation_name

	animation_playing.emit(true)

	anim_player.animation_finished.connect(on_animation_finished.bind(anim_player))

func on_animation_finished(anim_player: AnimationPlayer) -> void:
	dialogue_animation_finished.emit(false)

	# Disconnect the signal from the AnimationPlayer that was used to call this function
	# This is to avoid conflicts between AnimationPlayers
	anim_player.animation_finished.disconnect(self.on_animation_finished)


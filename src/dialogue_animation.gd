extends Node

func play_animation(character: String, animation_name: String) -> void:
	var route = "/root/MainScene/Characters/" + character + "/AnimationPlayer"
	var anim_player: AnimationPlayer = get_node(route)
	anim_player.current_animation = animation_name

extends Node

func play_animation(character: String, animation_name: String) -> void:
	var route = "/root/MainScene/Characters/" + character + "/AnimationPlayer"
	get_node(route).play(animation_name)

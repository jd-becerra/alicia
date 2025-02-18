extends Button

# This button displays dialogue depending on selected object 

@onready var dialogue_controller: DialogueController = %DialogueController

func show_interaction_dialogue(resource, dialogue_name: String) -> void:
	print("Dialogue button pressed")
	dialogue_controller.dialogue = resource
	dialogue_controller.start_dialogue(dialogue_name)

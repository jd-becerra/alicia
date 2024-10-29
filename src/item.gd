extends Resource
class_name Item

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: AtlasTexture = null

## The object that this item pairs with (could be Item or InteractionObject)
@export var pairs_with: String = ""

# Dictionary to store dialogue for incompatible items (key: item name, value: dialogue start name). Key: String, Value: String
@export var incompatible_dialogue: Dictionary = {}
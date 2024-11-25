extends Resource
class_name Item

@export var name: String = ""
@export_multiline var description: String = ""
@export var texture: AtlasTexture = null

## If the item is a default item and is present on the inventory at the start of the game
@export var default: bool = false

@export var is_document: bool = false
@export var document_path: String = ""

## Dictionary to store dialogue for incompatible items (key: item name, value: dialogue start name). Key: String, Value: String
@export var incompatible_dialogue: Array[String]

var index: int = -1
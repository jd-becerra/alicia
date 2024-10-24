extends Node
# Global script that handles the inventory system

@onready var inventory_interface: PanelContainer = $"/root/MainScene/UI/Menu/Inventory"
@onready var player: CharacterBody2D = $"/root/MainScene/Player"

func _ready() -> void:
	# Fill the inventory grid with the player's inventory data when the inventory interface is ready
	inventory_interface.ready.connect(set_inventory_data)

func set_inventory_data() -> void:	
	inventory_interface.set_inventory_data(player.inventory_data)

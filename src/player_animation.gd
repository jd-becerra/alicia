extends IndividualAnimationController

# This flag tells the Global Animation Controller if the player_animation position is spawnable
# If not, the player will be teleported to the nearest spawnable position
@export var spawnable = false 

func is_spawnable():
	return spawnable
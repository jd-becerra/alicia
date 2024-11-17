extends Control
# Simulate a piano with keys from G4 to G5

@onready var return_btn: Button = %ReturnBtn
@onready var game_ui: Control = %GameUI
@onready var pentagram: Sprite2D = %Pentagram
@onready var music_note: PackedScene = preload("res://scenes/music_note.tscn")
@onready var audio_stream_player = $AudioStreamPlayer
@onready var redo_btn: Button = %RedoBtn

# Constants
const KEYS = ["G4", "A4", "B4", "C5", "D5", "E5", "F5", "G5"]
const MAX_NOTES = 5  # Maximum number of notes to play before checking the sequence and resetting

const KEY_COLORS = {
	"G4": Color(1, 0, 0),       # Red
	"A4": Color(0, 0, 1),       # Blue
	"B4": Color(1, 0.75, 0.8),  # Pink
	"C5": Color(0.5, 1, 0),     # Lime
	"D5": Color(1, 0.5, 0),     # Orange
	"E5": Color(0, 0.5, 0),     # Dark Green
	"F5": Color(1, 1, 0),       # Yellow
	"G5": Color(0.5, 0, 0.5),   # Purple
}

# I don't know why the fuck these offsets work but they do, I hate Godot
const note_y_positions = {
	"G4": 100,
	"A4": 70,
	"B4": 30,
	"C5": 0,
	"D5": -30,
	"E5": -75,
	"F5": -110,
	"G5": -145,
}


const CORRECT_SEQUENCE = ["G4", "A4", "B4", "E5", "D5"]  # If player plays this sequence, they win
var player_sequence = []  # Player's current sequence
var printed_notes = []  # Notes that have been printed on the pentagram

var original_x: float
var original_y: float
var current_x: float

func _ready() -> void:
	# Search for the buttons in the scene (path: WhiteKeys/KEY)
	for key in KEYS:
		var button = %WhiteKeys.get_node(key)
		button.pressed.connect(print_note.bind(button))

	original_x = (pentagram.global_position.x - (pentagram.get_rect().size.x * pentagram.scale.x) / 2) - 150
	original_y = pentagram.global_position.y
	current_x = original_x
	return_btn.pressed.connect(_on_return_pressed)
	redo_btn.pressed.connect(clear_notes)

func _on_return_pressed() -> void:
	# Hide itself and show the game UI
	game_ui.show()
	self.hide()
	get_tree().paused = false

var rotated_left = false
func print_note(button: Button) -> void:
	if player_sequence.size() < MAX_NOTES:
		player_sequence.append(String(button.name))  # button.name is read as StringName, not String (thanks Godot)
		# Create a new music note on the pentagram
		var note = music_note.instantiate()
		note.position = set_note_position(button.name)
		note.modulate = KEY_COLORS[button.name]
		# Rotate note randomly between -10 and +10 degrees
		if rotated_left:
			note.rotation_degrees = randf_range(-5, 0)
		else:
			note.rotation_degrees = randf_range(0, 5)
		rotated_left = !rotated_left
		
		pentagram.add_child(note)
		current_x += 150
		printed_notes.append(note)

		# Play the note sound
		audio_stream_player.stream = load("res://sounds/piano_notes/" + String(button.name) + ".mp3")
		audio_stream_player.play()

		print("Player sequence: ", player_sequence)

	if player_sequence.size() == MAX_NOTES:
		if player_sequence == CORRECT_SEQUENCE:
			print("Congratulations! You played the correct sequence.")
			var main_scene = get_node("/root/MainScene")
			self.hide()
			get_tree().paused = false
			main_scene.enable_normal_animation("Scene1_Ending")
		else:
			print("Incorrect sequence. Try again.")
			
			# Make printed notes red
			for note in printed_notes:
				if is_instance_valid(note):
					note.modulate = Color(1, 0, 0)
			await get_tree().create_timer(2).timeout

			clear_notes()

func set_note_position(note_name: String) -> Vector2:
	# Set position of the note based on the current x position and the note position on a real pentagram
	return Vector2(current_x, original_y + note_y_positions[note_name])

func clear_notes() -> void:
	# Clear the sequence
	player_sequence.clear()
	current_x = original_x
	
	# Clear the notes safely
	for note in printed_notes:
		if is_instance_valid(note):  # Check if the note still exists
			note.queue_free()
	printed_notes.clear()  # Clear the array after freeing the notes

func show_use_node():
	if get_node("/root/MainScene/Objects/Piano/AnimationPlayer").current_animation == "Stuck":
		print("Piano is stuck, can't play it.")
		return

	game_ui.hide()
	self.show()
	get_tree().paused = true

	# If player has Partitura item (with index 2), show the PartituraCorrecta node
	if check_has_partitura():
		%PartituraCorrecta.show()

func check_has_partitura() -> bool:
	var items = get_node("/root/MainScene/Player").inventory_data.items
	for item in items:
		if item.index == 2:
			return true

	return false
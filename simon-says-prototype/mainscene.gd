extends Node2D

# Sequence array stores the sequence of button flashes as integers (steps) in order to remember and repeat the sequence on a successful round.
var sequence: Array[int] = []

# Player index variable is the user's input in the form of an integer.
var player_index: int = 0

# Buttons array stores the four colors as buttons which is initialized on scene start-up. Red == 0, Green == 1, Blue == 2, Yellow == 3.
var buttons: Array[Button] = []

# Button sound array stores the sound effects that play for each color. Red == 0, Green == 1, Blue == 2, Yellow == 3.
var buttonSounds: Array[AudioStreamPlayer] = []

# Input enabled variable checks to se when inputs are active or not.
var input_enabled: bool = false

# Integer points increases after every successful sequence input.
var points: int = 0

#Points text
@onready var label: Label = $Panel/Label
#Game Over screen text.
@onready var game_over_text: Label = $GameOverText




# The _ready() function is called upon scene initialization.
func _ready():
	buttons = [$RedButton, $GreenButton, $BlueButton, $YellowButton]
	buttonSounds = [$RedSound, $GreenSound, $BlueSound, $YellowSound]
	start_game()


# Starts the first sequence.
func start_game():
	sequence.clear()
	await get_tree().create_timer(1.0).timeout # This is for a delay of 1 second
	add_random_step()
	await play_sequence() # Pauses all other processes except for what is written in this function. Resumes when function has been fully called.


# Adds a new step to the sequence. The new step is always random.
func add_random_step():
	sequence.append(randi() % buttons.size())


#Plays the full sequence by looping through the sequence with a 0.2 second delay for each step
func play_sequence():
	input_enabled = false
	for idx in sequence:
		var button = buttons[idx]
		var buttonSound = buttonSounds[idx]
		await play_sound(buttonSound)
		await flash_button(button)
		await get_tree().create_timer(0.2).timeout
	player_index = 0
	input_enabled = true


# The buttons are rectangles that can be lightened briefly to indicate flashing.
func flash_button(button: Button):
	var color_rect = button.get_node("ColorRect") as ColorRect
	var original_color = color_rect.color
	var flashing_color = original_color.lightened(0.2)
	
	color_rect.color = flashing_color
	input_enabled = false
	await get_tree().create_timer(0.3).timeout
	color_rect.color = original_color
	input_enabled = true


# This function is called when the button that corresponds to the parameter integer is pressed.
func _on_button_pressed(idx: int):
	
	# If inputs are disabled, do nothing.
	if not input_enabled:
		return
	
	
	# Before anything else, plays the sound and flashes the button.
	await play_sound(buttonSounds[idx])
	await flash_button(buttons[idx])
	
	
	# Lets say Red == 0, which makes idx == 0, and lets say player_index == 0, so that means sequence[player_index] will be the first step in the sequence. If idx and the step match, then move on to the next step.
	if sequence[player_index] == idx:
		player_index += 1
		
		# If the next step marks the end of the sequence in that round, add a new step, then play the sequence from the beginning.
		if player_index >= sequence.size():
			add_point()
			add_random_step()
			await get_tree().create_timer(1.0).timeout
			await play_sequence()
			
	# The player chose the wrong step in the sequence.
	else:
		input_enabled = false
		points = 0
		label.text = "Points: 0"
		print("Game Over!")
		game_over_text.visible = true
		game_over_text.text = "Game Over! Game restarting in 3"
		await get_tree().create_timer(1.0).timeout
		game_over_text.text = "Game Over! Game restarting in 2"
		await get_tree().create_timer(1.0).timeout
		game_over_text.text = "Game Over! Game restarting in 1"
		await get_tree().create_timer(1.0).timeout
		game_over_text.visible = false
		start_game()


# Plays the mp3 file corresponding to the color.
func play_sound(buttonSound: AudioStreamPlayer):
	buttonSound.play()


func add_point():
	points += 1
	label.text = "Points: " + str(points)


# Red == 0
func _on_red_button_pressed() -> void:
	_on_button_pressed(0)


# Green == 1
func _on_green_button_pressed() -> void:
	_on_button_pressed(1)


# Blue == 2
func _on_blue_button_pressed() -> void:
	_on_button_pressed(2)


# Yellow == 3
func _on_yellow_button_pressed() -> void:
	_on_button_pressed(3)

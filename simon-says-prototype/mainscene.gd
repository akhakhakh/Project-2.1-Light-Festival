extends Node2D

# Sequence array stores the sequence of button flashes as integers (steps) in order to remember and repeat the sequence on a successful round.
var sequence: Array[int] = []

# Player index variable is the user's input in the form of an integer.
var player_index: int = 0

# Buttons array stores the four colors as buttons which is initialized on scene start-up. Red == 0, Green == 1, Blue == 2, Yellow == 3.
var buttons: Array[Button] = []

# Button sound array stores the sound effects that play for each color. Red == 0, Green == 1, Blue == 2, Yellow == 3.
var buttonSounds: Array[AudioStreamPlayer] = []

# Particles that play when a button is pressed
var buttonParticles: Array[CPUParticles2D] = []

# Input enabled variable checks to se when inputs are active or not.
var input_enabled: bool = false

# Integer points increases after every successful sequence input.
var points: int = 0

# Milestone booleans
var reached_5_points = false
var reached_10_points = false
var reached_20_points = false

#Points text
@onready var label: Label = $Panel/Label

#Game Over screen text.
@onready var game_over_text: Label = $GameOverText

# Sound that plays when a milestone is reached
@onready var combo: AudioStreamPlayer = $Combo

# Background filled with stars using a shader
@onready var background: ColorRect = $Background

# Text that appears when a milestone is met
@onready var combo_message: Label = $ComboMessage

# The _ready() function is called upon scene initialization.
func _ready():
	buttons = [$RedButton, $GreenButton, $BlueButton, $YellowButton]
	buttonSounds = [$RedSound, $GreenSound, $BlueSound, $YellowSound]
	buttonParticles = [$RedParticles, $GreenParticles, $BlueParticles, $YellowParticles]
	start_game()


func _process(float):
	var mat = background.material
	
	if points == 5 && reached_5_points == false:
		display_combo_text()
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/near_stars_color", Color.from_rgba8(254, 144, 0, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(mat, "shader_parameter/far_stars_color", Color.from_rgba8(255, 202, 142, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combo.play()
		reached_5_points = true

	if points == 10 && reached_10_points == false:
		display_combo_text()
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/near_stars_color", Color.from_rgba8(255, 38, 121, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(mat, "shader_parameter/far_stars_color", Color.from_rgba8(255, 155, 177, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combo.play()
		reached_10_points = true
		
	if points == 20 && reached_20_points == false:
		display_combo_text()
		var tween = create_tween()
		tween.tween_property(mat, "shader_parameter/near_stars_color", Color.from_rgba8(168, 159, 255, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(mat, "shader_parameter/far_stars_color", Color.from_rgba8(153, 255, 184, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		combo.play()
		reached_10_points = true

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
	var mat = color_rect.material
	input_enabled = false

	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/flash_strength", 0.5, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(mat, "shader_parameter/flash_strength", 0.0, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	await tween.finished
	input_enabled = true

# Particles attached to each button will be emitted
func emit_particles(buttonParticles : CPUParticles2D):
	buttonParticles.emitting = false
	buttonParticles.restart() 
	buttonParticles.emitting = true

# This function is called when the button that corresponds to the parameter integer is pressed.
func _on_button_pressed(idx: int):
	
	# If inputs are disabled, do nothing.
	if not input_enabled:
		return
	
	
	# Before anything else, plays the sound and flashes the button.
	await play_sound(buttonSounds[idx])
	await emit_particles(buttonParticles[idx])
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
		lose_game()

func lose_game():
	input_enabled = false
	return_background_to_white()
	LeaderboardManager.current_player_score = points
	
	if LeaderboardManager.current_player_name != "":
		if points > 0:
			LeaderboardManager.add_score(LeaderboardManager.current_player_name, points)
			print("Saved score for", LeaderboardManager.current_player_name, ":", points)

	points = 0
	label.text = "Points: 0"
	get_tree().change_scene_to_file("res://game_over.tscn")

func return_background_to_white():
	reached_5_points = false
	reached_10_points = false
	reached_20_points = false
	
	var mat = background.material
	var tween = create_tween()
	tween.tween_property(mat, "shader_parameter/near_stars_color", Color.from_rgba8(255, 255, 255, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.tween_property(mat, "shader_parameter/far_stars_color", Color.from_rgba8(255, 255, 255, 255), 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
# Plays the mp3 file corresponding to the color.
func play_sound(buttonSound: AudioStreamPlayer):
	buttonSound.play()

func display_combo_text():
	combo_message.visible = true
	
	var tween_movement = create_tween()
	tween_movement.tween_property(combo_message, "position", Vector2(combo_message.position.x, 200.0), 1.0)
	
	var tween_fade_out = create_tween()
	tween_fade_out.tween_property(combo_message, "modulate:a", 0.0, 1.0)
	
	await get_tree().create_timer(1.0).timeout
	combo_message.visible = false
	
	var tween_fade_in = create_tween()
	tween_fade_in.tween_property(combo_message, "modulate:a", 1.0, 1.0)

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

func _input(event):
	if event.is_action_pressed("red_button"):
		_on_red_button_pressed()

	elif event.is_action_pressed("green_button"):
		_on_green_button_pressed()

	elif event.is_action_pressed("blue_button"):
		_on_blue_button_pressed()

	elif event.is_action_pressed("yellow_button"):
		_on_yellow_button_pressed()

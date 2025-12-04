extends AudioStreamPlayer2D

@onready var button_sound = preload("res://rhythmgame_folder/rhythmgame_assets/music/soundEffects/button_click.mp3")

func play_button_sound():
	if button_sound:
		stream = button_sound
		play()

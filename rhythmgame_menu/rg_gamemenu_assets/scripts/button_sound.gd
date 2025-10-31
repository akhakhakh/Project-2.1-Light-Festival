extends AudioStreamPlayer2D

@onready var audio_player = $AudioStreamPlayer
@onready var button_sound = preload("res://rhythmgame_menu/rg_gamemenu_assets/soundEffects/button_click.mp3")

func play_button_sound():
	if audio_player and button_sound:
		audio_player.stream = button_sound
		audio_player.play()

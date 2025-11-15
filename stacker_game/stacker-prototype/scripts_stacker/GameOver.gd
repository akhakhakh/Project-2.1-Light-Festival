extends Node2D

@onready var score_label = $Label
@onready var restart_button = $RestartButton

func _ready():
	# Display the final score stored in the global singleton
	if score_label:
		score_label.text = "You got " + str(Global.score) + "pts!"
	else:
		push_error("ScoreLabel node not found!")

func _input(event):
	if event.is_action_pressed("green_button"):
		get_tree().change_scene_to_file("res://scenes_stacker/Main.tscn")

	elif event.is_action_pressed("yellow_button"):
		get_tree().change_scene_to_file("res://scenes_stacker/TitleScreen.tscn")
		
	elif event.is_action_pressed("blue_button"):
		get_tree().change_scene_to_file("res://scenes_stacker/LeaderboardScreen.tscn")

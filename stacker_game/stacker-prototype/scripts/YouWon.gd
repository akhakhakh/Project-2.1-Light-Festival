extends Node2D

@onready var score_label = $Label
@onready var restart_button = $Button

func _ready():
	if score_label:
		score_label.text = "Score: " + str(Global.score)
	else:
		push_error("ScoreLabel node not found!")

	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	else:
		push_error("RestartButton node not found!")

func _on_restart_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

extends Control

@onready var score: Label = $VBoxContainer/Score


var player_name: String
var player_score: int

func _ready() -> void:

	player_name = LeaderboardManager.current_player_name
	player_score = LeaderboardManager.current_player_score
	
	score.text = "%s — Your score was: %d" % [player_name, player_score]
	
func _input(event):
	if event.is_action_pressed("red_button"):
		get_tree().change_scene_to_file("res://mainscene.tscn")

	elif event.is_action_pressed("blue_button"):
		get_tree().change_scene_to_file("res://titlescreen.tscn")

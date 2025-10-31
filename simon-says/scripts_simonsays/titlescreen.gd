extends Control

func _ready() -> void:
	LeaderboardManager.current_player_name = ""
	LeaderboardManager.current_player_score = 0

func _input(event):
	if event.is_action_pressed("red_button"):
		get_tree().change_scene_to_file("res://scenes_simonsays/name_entry.tscn")

	elif event.is_action_pressed("green_button"):
		get_tree().change_scene_to_file("res://scenes_simonsays/leaderboard_screen.tscn")

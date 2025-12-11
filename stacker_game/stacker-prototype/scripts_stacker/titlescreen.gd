extends Control

func _ready() -> void:
	print("Title screen ready called")
	LeaderboardManager.current_player_name = ""
	LeaderboardManager.current_player_score = 0
	print("LeaderBoardManager initialised")

func _input(event):
	if event.is_action_pressed("red_button"):
		get_tree().change_scene_to_file("res://scenes_stacker/NameEntry.tscn")

	elif event.is_action_pressed("green_button"):
		get_tree().change_scene_to_file("res://scenes_stacker/LeaderboardScreen.tscn")
	
	elif event.is_action_pressed("white_button"):
		get_tree().quit()

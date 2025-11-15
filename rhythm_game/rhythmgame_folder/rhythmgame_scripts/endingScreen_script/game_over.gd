# GameOver.gd
extends Control

func _ready():
	var score = Global.total_score
	var score_label = get_node("VBoxContainer/ScoreLabel")
	score_label.text = "Your score was: " + str(score)

# Called by your colored buttons or keys
func _on_button_pressed(index: int) -> void:
	match index:
		0:
			get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/easy_level/game_level.tscn")

		1:
			get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/easy_level/game_level.tscn")

		_:
			print("Invalid index: ", index)

# Button pressed functions
func _on_red_button_pressed() -> void:
	_on_button_pressed(0)

func _on_blue_button_pressed() -> void:
	_on_button_pressed(1)

# Optional: handle keyboard input
func _input(event):
	if event.is_action_pressed("button_W"):
		_on_red_button_pressed()
	elif event.is_action_pressed("button_E"):
		_on_blue_button_pressed()

extends Node2D


# Called when the node enters the scene tree for the first time.
func _input(event):
	if event.is_action_pressed("red_button"):
		get_tree().change_scene_to_file("res://scenes/NameEntry.tscn")
		
	elif event.is_action_pressed("yellow_button"):
		get_tree().change_scene_to_file("res://scenes/TitleScreen.tscn")

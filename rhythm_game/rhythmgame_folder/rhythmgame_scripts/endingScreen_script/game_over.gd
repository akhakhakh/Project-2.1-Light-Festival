# GameOver.gd
extends Control

func _ready():
	var score = Global.total_score
	var score_label = get_node("VBoxContainer/ScoreLabel")
	score_label.text = "Your score was: " + str(score)

# Called by your colored buttons or keys
func _on_button_pressed(index: int) -> void:
	BeatManagerEasyLevel.Reset()
	BeatManagerMedium.Reset()
	BeatManagerJingleBells.Reset()
	Global.reset_game_stats()
	match index:
		0:
			get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/rg_menu_scenes/difficulty_menu.tscn")

		1:
			get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/rg_menu_scenes/main_page.tscn")

		_:
			print("Invalid index: ", index)

# Button pressed functions
func _on_red_button_pressed() -> void:
	_on_button_pressed(0)

func _on_blue_button_pressed() -> void:
	_on_button_pressed(1)

func _on_yellow_button_pressed() -> void:
	_on_button_pressed(2)

func _on_green_button_pressed() -> void:
	_on_button_pressed(3)
	
func is_beat_manager_active(beat_manager) -> bool:
	if beat_manager == null:
		return false
	
	# Check all children for AudioStreamPlayer
	for child in beat_manager.get_children():
		if child is AudioStreamPlayer:
			# Check if it's playing
			if child.is_playing():
				return true
	
	return false
	
# Optional: handle keyboard input
func _input(event):
	if event.is_action_pressed("red_button"):
		_on_red_button_pressed()
	elif event.is_action_pressed("blue_button"):
		_on_blue_button_pressed()
	elif event.is_action_pressed("green_button"):  
		_on_yellow_button_pressed()
	elif event.is_action_pressed("yellow_button"): 
		_on_green_button_pressed()

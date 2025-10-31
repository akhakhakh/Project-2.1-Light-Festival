extends Control

@onready var letter_labels = [
	$VBoxContainer/HBoxContainer/Label,
	$VBoxContainer/HBoxContainer/Label2,
	$VBoxContainer/HBoxContainer/Label3
]

var letters = ["A", "A", "A"]
var current_index := 0
var alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func _ready():
	update_display()
	highlight_current()

func _input(event):
	if event.is_action_pressed("blue_button"):
		change_letter(1)
	elif event.is_action_pressed("red_button"):
		change_letter(-1)
	elif event.is_action_pressed("green_button"):
		confirm_letter()
	elif event.is_action_pressed("yellow_button"):
		get_tree().change_scene_to_file("res://scenes_simonsays/titlescreen.tscn")

func change_letter(direction: int):
	var idx = alphabet.find(letters[current_index])
	if idx == -1:
		idx = 0
	idx = (idx + direction) % alphabet.length()
	letters[current_index] = alphabet[idx]
	update_display()

func confirm_letter():
	current_index += 1
	if current_index < letters.size():
		highlight_current()
	else:
		confirm_name()

func update_display():
	for i in range(letters.size()):
		letter_labels[i].text = letters[i]

func highlight_current():
	for i in range(letter_labels.size()):
		letter_labels[i].modulate = Color.WHITE
	if current_index < letter_labels.size():
		letter_labels[current_index].modulate = Color(1, 1, 0) 

func confirm_name():
	var name_chosen = "".join(letters)
	LeaderboardManager.current_player_name = name_chosen
	print("Player name set to:", name_chosen)
	get_tree().change_scene_to_file("res://scenes_simonsays/mainscene.tscn")

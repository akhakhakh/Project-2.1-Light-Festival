extends Control

const CHARSET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
var generated_id: String = ""

@onready var id: Label = $VBoxContainer/ID


func _ready() -> void:
	generated_id = generate_id()
	id.text = generated_id

func _input(event):
	if event.is_action_pressed("yellow_button"):
		get_tree().change_scene_to_file("res://scenes_simonsays/titlescreen.tscn")
	elif event.is_action_pressed("green_button"):
		confirm_name()
		get_tree().change_scene_to_file("res://scenes_simonsays/mainscene.tscn")

func confirm_name():
	LeaderboardManager.current_player_name = generated_id
	print("Player ID set to:", generated_id)

func generate_id(length: int = 8) -> String:
	var code := ""
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	for i in length:
		code += CHARSET[rng.randi_range(0, CHARSET.length() - 1)]
	return code

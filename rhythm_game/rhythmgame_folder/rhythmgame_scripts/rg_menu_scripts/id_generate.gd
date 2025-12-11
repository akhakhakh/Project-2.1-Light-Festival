extends Control

const CHARSET := "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
var generated_id: String = ""

@onready var id: Label = $ID


func _ready() -> void:
	generated_id = generate_id()
	id.text = generated_id

func _input(event):
	if event.is_action_pressed("red_button"):
		confirm_name()
		get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/rg_menu_scenes/difficulty_menu.tscn")

func confirm_name():
	Global.player_id = generated_id
	print("Player ID set to:", generated_id)

func generate_id(length: int = 8) -> String:
	var code := ""
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	for i in length:
		code += CHARSET[rng.randi_range(0, CHARSET.length() - 1)]
	return code

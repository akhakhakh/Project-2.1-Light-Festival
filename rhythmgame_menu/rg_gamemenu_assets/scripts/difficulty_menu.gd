extends Control

signal easy_selected
signal medium_selected
signal hard_selected
signal back_pressed

#reference
@onready var easy_button = $EasyButton
@onready var medium_button = $MediumButton
@onready var hard_button = $HardButton
@onready var back_button = $BackButton

#animation-ref
@onready var animation_player = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	easy_button.pressed.connect(_on_easy_button_pressed)
	medium_button.pressed.connect(_on_medium_button_pressed)
	hard_button.pressed.connect(_on_hard_button_pressed)
	
	#connection debug
	if back_button:
		back_button.pressed.connect(_on_back_button_pressed)
	else:
		print("ERROR: BackButton node not found!")

func play_enter_animation():
	animation_player.play("bounce_in_from_right") #called by main_page.gd for transition

func play_exit_animation():
	animation_player.play("bounce_out_to_right")

func _on_easy_button_pressed():
	print("Easy difficulty selected")
	emit_signal("easy_selected")

func _on_medium_button_pressed():
	print("Medium difficulty selected")
	emit_signal("medium_selected")

func _on_hard_button_pressed():
	print("Hard difficulty selected")
	emit_signal("hard_selected")

func _on_back_button_pressed():
	print("Returning to Menu")
	emit_signal("back_pressed")
	get_tree().change_scene_to_file("res://rhythmgame_menu/rg_gamemenu_assets/scenes/main_page.tscn")

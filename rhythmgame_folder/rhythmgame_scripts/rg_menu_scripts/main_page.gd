extends Node2D

#Reference
@onready var startup_page: Control
@onready var difficulty_menu = preload("res://rhythmgame_folder/rhythmgame_scenes/rg_menu_scenes/difficulty_menu.tscn")
@onready var button_sound = $ButtonSound

# Called when the node enters the scene tree for the first time.
func _ready():
	#reference startup page
	startup_page = $CanvasLayer/StartUpPage
	startup_page.ready.connect(_on_startup_page_ready)
	
	print("Main scene loaded - Pixel Rhythm Game")

func _on_startup_page_ready():
	# Connect signals from startup page
	startup_page.start_button_pressed.connect(_on_start_button_pressed())
	startup_page.leaderboard_button_pressed.connect(_on_leaderboard_button_pressed())
	startup_page.quit_button_pressed.connect(_on_quit_button_pressed())
	
	print("Startup Page signals connected successfully")


func _on_start_button_pressed():
	_play_button_sound()
	print("Transitioning to difficulty menu...")
	get_tree().change_scene_to_file("res://rhythmgame_scenes/rg_menu_scenes/difficulty_menu.tscn")

func _on_leaderboard_button_pressed():
	_play_button_sound()
	print("Opening leaderboard...")
	#get_tree().change_scene_to_file(#add the leaderboard scene here)

func _on_quit_button_pressed():
	_play_button_sound()
	get_tree().quit()

func _play_button_sound():
	if button_sound:
		button_sound.play()

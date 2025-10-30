extends Node2D

#Reference
var startup_page: Control

# Called when the node enters the scene tree for the first time.
func _ready():
	#reference startup page
	startup_page = $CanvasLayer/StartUpPage
	
	startup_page.ready.connect(_on_startup_page_ready)
	
	print("Main scene loaded - Pixel Rhythm Game")
	

func _on_startup_page_ready():
	# Connect signals from startup page
	startup_page.start_button_pressed.connect(_on_startup_start_button_pressed())
	startup_page.leaderboard_button_pressed.connect(_on_startup_leaderboard_button_pressed())
	
	print("Startup Page signals connected successfully")


func _on_startup_start_button_pressed():
	print("Transitioning to difficulty selection...")

func _on_startup_leaderboard_button_pressed():
	print("Opening leaderboard...")

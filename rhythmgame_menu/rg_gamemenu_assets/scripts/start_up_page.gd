extends Control

#communicate with main_page.gd
signal start_button_pressed 
signal leaderboard_button_pressed

#reference to UI elements
@onready var start_button = $StartButton
@onready var leaderboard_button = $LeaderboardButton
@onready var background: TextureRect = $Background

# Called when the node enters the scene tree for the first time.
func _ready():
	#full screen
	_setup_fullscreen_layout()
	
	# Connect button signals to functions
	start_button.connect("pressed", _on_start_button_pressed)
	leaderboard_button.connect("pressed", _on_leaderboard_button_pressed)
	
	#Set up initial focus for buttons/gamepad support
	start_button.grab_focus()
	
	print("Startup page loded successfully!")

func _on_start_button_pressed():
	print("Start button pressed")
	emit_signal("start_button_pressed")

func _on_leaderboard_button_pressed():
	print("Leaderboard button pressed")
	emit_signal("leaderboard_button_pressed")

#styling 
func _setup_fullscreen_layout():
	#get screen size
	var screen_size = get_viewport_rect().size
	
	#fill the entire screen
	size = screen_size
	
	if background:
		background.size = screen_size

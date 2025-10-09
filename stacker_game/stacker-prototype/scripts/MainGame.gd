extends Node

@onready var start_button = $StartButton

func _ready():
	# pause the game when the scene loads
	get_tree().paused = true
	start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed():
	get_tree().paused = false
	start_game()

func start_game():
	# Your normal game starting logic here
	pass

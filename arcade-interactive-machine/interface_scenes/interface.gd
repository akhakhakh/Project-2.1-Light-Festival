extends Control

@onready var arrow := $arrow
@onready var markers := [
	$markers/Marker2D,
	$markers/Marker2D2,
	$markers/Marker2D3
]

var game_files := [
	"Simon Says.exe",     
	"Rhythm Game.exe",     
	"Stacker.exe"          
]

var selected_index: int = 0
var tween: Tween

func _ready() -> void:
	arrow.global_position = markers[selected_index].global_position

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("green_button"):
		select_previous()
	elif event.is_action_pressed("yellow_button"):
		select_next()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("red_button"):
		launch_current_game()

func launch_current_game():
	var exe_name = game_files[selected_index]
	launch_game(exe_name)

func select_next() -> void:
	selected_index = (selected_index + 1) % markers.size()
	move_arrow_to_selected()


func select_previous() -> void:
	selected_index = (selected_index - 1 + markers.size()) % markers.size()
	move_arrow_to_selected()


func move_arrow_to_selected() -> void:
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(arrow, "global_position", markers[selected_index].global_position, 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func launch_game(exe_name: String):
	var path = ProjectSettings.globalize_path("res://exports/" + exe_name)

	if not FileAccess.file_exists("res://exports/" + exe_name):
		push_error("File not found: " + exe_name)
		return

	var result = OS.create_process(path, [])
	if result == null:
		push_error("Failed to launch " + exe_name)
	else:
		print("Launched:", exe_name)

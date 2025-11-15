extends Control

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

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("red_button"):
		launch_game("Simon Says.exe")
	if event.is_action_pressed("blue_button"):
		launch_game("Stacker.exe")
	if event.is_action_pressed("green_button"):
		launch_game("Rhythm Game.exe")

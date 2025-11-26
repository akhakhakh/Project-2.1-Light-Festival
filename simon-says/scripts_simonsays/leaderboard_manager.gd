extends Node

var current_player_name: String = ""
var current_player_score: int = 0
const SAVE_PATH := "user://leaderboard_simonsays.tres"
var leaderboard_data: LeaderboardData
const SHARED_JSON := "C:/Users/aradk/Documents/GitHub/Project-2.1-Light-Festival/leaderboard.json"
var game: String = "SimonSays"

func _ready():
	load_leaderboard()

func load_leaderboard():
	if FileAccess.file_exists(SAVE_PATH):
		leaderboard_data = ResourceLoader.load(SAVE_PATH)
	else:
		leaderboard_data = LeaderboardData.new()
		save_leaderboard()

func save_leaderboard():
	ResourceSaver.save(leaderboard_data, SAVE_PATH)

func add_score(name: String, score: int):
	leaderboard_data.add_entry(name, score)
	save_leaderboard()
	_update_shared_json(name, score, game)

func get_leaderboard() -> Array:
	return leaderboard_data.entries

func clear_leaderboard():
	leaderboard_data.entries.clear()
	save_leaderboard()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clear_leaderboard"):
		clear_leaderboard()
		print("Leaderboard cleared")

func get_high_score() -> int:
	if leaderboard_data.entries.is_empty():
		return 0

	var highest := 0
	for entry in leaderboard_data.entries:
		if entry.score > highest:
			highest = entry.score
	return highest

func _update_shared_json(name: String, score: int, game: String):
	var data: Array = []

	# Load existing JSON if it exists
	if FileAccess.file_exists(SHARED_JSON):
		var file = FileAccess.open(SHARED_JSON, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			if text != "":
				var parsed = JSON.parse_string(text)
				if typeof(parsed) == TYPE_ARRAY:
					data = parsed

	# Append new entry
	data.append({"name": name, "score": score, "game": game})

	# Ensure folder exists
	var folder = SHARED_JSON.get_base_dir()
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_absolute(folder)

	# Save back to JSON
	var file_save = FileAccess.open(SHARED_JSON, FileAccess.WRITE)
	if file_save == null:
		push_error("Cannot open JSON file at: " + SHARED_JSON)
		return

	file_save.store_string(JSON.stringify(data))
	file_save.close()

	print("✅ Saved score to shared JSON at:", SHARED_JSON)

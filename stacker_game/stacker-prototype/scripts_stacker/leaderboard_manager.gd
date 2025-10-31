extends Node

var current_player_name: String = ""
var current_player_score: int = 0
const SAVE_PATH := "user://leaderboard_stacker.tres"
var leaderboard_data: LeaderboardData

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

func add_score(username: String, score: int):
	leaderboard_data.add_entry(username, score)
	save_leaderboard()

func get_leaderboard() -> Array:
	return leaderboard_data.entries

func username_exists(username: String) -> bool:
	for entry in leaderboard_data.entries:
		if entry["name"] == username:
			return true
	return false

func clear_leaderboard():
	leaderboard_data.entries.clear()
	save_leaderboard()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("clear_leaderboard"):
		clear_leaderboard()
		print("Leaderboard cleared")

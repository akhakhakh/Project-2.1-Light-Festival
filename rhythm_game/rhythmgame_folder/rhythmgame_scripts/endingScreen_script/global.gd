extends Node

var total_score: int = 0
var combo_count: int = 0
var miss_count: int = 0
var song_name: String = ""
var player_id: String = ""
var leaderboard_data: LeaderboardData
const SHARED_JSON := "C:/Users/aradk/Documents/GitHub/Project-2.1-Light-Festival/leaderboard.json"
var game: String = "RhythmGame"

# Debounce to prevent multiple miss increments within a short time window (seconds)
var _last_miss_time: float = -10.0
const MISS_DEBOUNCE_SECONDS := 0.12

func increment_combo():
	combo_count += 1

# Call this instead of modifying miss_count directly
func register_miss() -> bool:
	var now: float = Time.get_ticks_msec() / 1000.0
	
	if now - _last_miss_time < MISS_DEBOUNCE_SECONDS:
		return false
		
	_last_miss_time = now
	miss_count += 1
	print("Global.register_miss -> miss_count:", miss_count, "time:", now)
	
	return true
	
func reset_combo():
	combo_count = 0	
	
func reset_game_stats():
	miss_count = 0
	total_score = 0
	combo_count = 0
	_last_miss_time = -10.0

func add_score(name: String, score: int):
	leaderboard_data.add_entry(name, score)
	_update_shared_json(name, score, game)

func _update_shared_json(name: String, score: int, game: String):
	var data: Array = []
	
	if FileAccess.file_exists(SHARED_JSON):
		var file = FileAccess.open(SHARED_JSON, FileAccess.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			if text != "":
				var parsed = JSON.parse_string(text)
				if typeof(parsed) == TYPE_ARRAY:
					data = parsed
	
	data.append({"name": name, "score": score, "game": game})
	
	var folder = SHARED_JSON.get_base_dir()
	if not DirAccess.dir_exists_absolute(folder):
		DirAccess.make_dir_absolute(folder)
	
	var file_save = FileAccess.open(SHARED_JSON, FileAccess.WRITE)
	if file_save == null:
		push_error("Cannot open JSON file at: " + SHARED_JSON)
		return
	
	file_save.store_string(JSON.stringify(data))
	file_save.close()
	print("Saved score to shared JSON at:", SHARED_JSON)

extends Node

var total_score: int = 0
var combo_count: int = 0
var miss_count: int = 0
var song_name: String = ""

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

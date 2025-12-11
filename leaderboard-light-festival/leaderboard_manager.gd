extends Node

const SHARED_JSON := "C:/Users/aradk/Documents/GitHub/Project-2.1-Light-Festival/leaderboard.json"

var simon_says_entries: Array = []
var stacker_entries: Array = []
var rhythmgame_entries: Array = []

func _ready():
	load_shared_json()


func load_shared_json():
	simon_says_entries.clear()
	stacker_entries.clear()
	rhythmgame_entries.clear()
	
	if not FileAccess.file_exists(SHARED_JSON):
		print("JSON not found:", SHARED_JSON)
		return
	
	var file := FileAccess.open(SHARED_JSON, FileAccess.READ)
	if file == null:
		print("Cannot open JSON:", SHARED_JSON)
		return
	
	var text := file.get_as_text()
	file.close()
	
	if text == "":
		print("JSON file empty")
		return
	
	var parsed: Variant = JSON.parse_string(text)
	if typeof(parsed) != TYPE_ARRAY:
		print("JSON not an array")
		return
	
	# Filter only entries for SimonSays
	for entry in parsed:
		if entry.has("game") and entry["game"] == "SimonSays":
			simon_says_entries.append(entry)
	
	# Filter only entires for Stacker
	for entry in parsed:
		if entry.has("game") and entry["game"] == "Stacker":
			stacker_entries.append(entry)
	
	for entry in parsed:
		if entry.has("game") and entry["game"] == "RhythmGame":
			rhythmgame_entries.append(entry)

	# Sort by score (DESC)
	simon_says_entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	stacker_entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	rhythmgame_entries.sort_custom(func(a, b): return int(a["score"]) > int(b["score"]))
	print("SimonSays entries loaded:", simon_says_entries)
	print("Stacker entries loaded:", stacker_entries)
	print("RhythmGame entries loaded:", rhythmgame_entries)

func reset_all_leaderboards():
	var empty_array: Array = []
	var file = FileAccess.open(SHARED_JSON, FileAccess.WRITE)
	file.store_string(JSON.stringify(empty_array))
	file.close()

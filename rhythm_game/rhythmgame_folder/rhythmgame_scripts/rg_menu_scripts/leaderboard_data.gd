extends Resource
class_name LeaderboardData

@export var entries: Array[Dictionary] = [] 

func add_entry(name: String, score: int):
	entries.append({ "name": name, "score": score })
	entries.sort_custom(func(a, b): return a["score"] > b["score"])
	if entries.size() > 10:
		entries.resize(10)

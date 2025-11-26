extends Control

@onready var simon_entries_container := $HBoxContainer/SimonSaysContainer/VBoxContainer
@onready var timer: Timer = $Timer
@onready var rows: Node = $HBoxContainer/SimonSaysContainer/VBoxContainer/Rows

func _ready():
	LeaderboardManager.load_shared_json()
	update_all_leaderboards()

func _create_row(name: String, score: int) -> HBoxContainer:
	var row = HBoxContainer.new()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var name_label = Label.new()
	name_label.text = name
	name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var score_label = Label.new()
	score_label.text = str(score)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	row.add_child(name_label)
	row.add_child(score_label)
	return row
	
func update_all_leaderboards():
	for c in rows.get_children(): c.queue_free()

	# Simon Says
	for entry in LeaderboardManager.simon_says_entries:
		var row = _create_row(entry["name"], entry["score"])
		rows.add_child(row)

func _on_timer_timeout() -> void:
	LeaderboardManager.load_shared_json()
	update_all_leaderboards()

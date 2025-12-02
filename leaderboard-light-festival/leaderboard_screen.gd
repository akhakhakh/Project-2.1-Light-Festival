extends Control

@onready var simon_entries_container := $LeaderboardContainer/SimonSaysContainer/VBoxContainer
@onready var timer: Timer = $Timer
@onready var rows: Node = $LeaderboardContainer/SimonSaysContainer/VBoxContainer/Rows
@onready var countdown_timer: Timer = $TIMER/Panel/CountdownTimer
@onready var timer_text: Label = $TIMER/Panel/TimerText

var total_seconds := 3600

func _ready():
	LeaderboardManager.load_shared_json()
	update_all_leaderboards()
	update_label()
	countdown_timer.start()

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

func update_label() -> void:
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	timer_text.text = "%02d:%02d" % [minutes, seconds]

func _on_countdown_timer_timeout() -> void:
	total_seconds -= 1
	if total_seconds <= 0:
		total_seconds = 0
		countdown_timer.stop()
	update_label()

func reset_timer():
	total_seconds = 3600
	update_label()
	countdown_timer.start()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("reset_leaderboard"):
		LeaderboardManager.reset_all_leaderboards()
		reset_timer()

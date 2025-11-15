extends Control

@onready var leaderboard_list: VBoxContainer = $MarginContainer/VBoxContainer/LeaderboardList


func _ready():
	update_leaderboard()

func update_leaderboard():
	for child in leaderboard_list.get_children():
		child.queue_free()

	var entries = LeaderboardManager.get_leaderboard()

	for entry in entries:
		var row = HBoxContainer.new()
		row.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var name_label = Label.new()
		name_label.text = entry["name"]
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		var score_label = Label.new()
		score_label.text = str(entry["score"])
		score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL

		row.add_child(name_label)
		row.add_child(score_label)
		leaderboard_list.add_child(row)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("yellow_button"):
		get_tree().change_scene_to_file("res://scenes_simonsays/titlescreen.tscn")

extends Control

# Variables to store the total score and current combo count
#var score: int = 0
#var combo_count: int = 0

# Called once when the node enters the scene tree
func _ready():
	# Connect custom game signals to local functions
	# so the UI automatically updates when score or combo changes
	Signals.IncrementScore.connect(_on_score_changed)
	Signals.IncrementCombo.connect(_on_combo_incremented)
	Signals.ResetCombo.connect(_on_combo_reset)
	
	# Increment 
	UpdateScoreDisplay()
	UpdateComboDisplay()
	
	# Reset combo when the game starts
	_on_combo_reset()

# Increases the score by a given amount
# 'incr' is the number of points to add
func UpdateScoreDisplay():
	%ScoreLabel.text = " " + str(Global.total_score) + " points"

func UpdateComboDisplay():
	if Global.combo_count > 0:
		%ComboLabel.text = " " + str(Global.combo_count) + "x combo"
	else:
		%ComboLabel.text = ""

func _on_score_changed(_incr: int):
	UpdateScoreDisplay()

func _on_combo_incremented():
	Global.increment_combo()
	UpdateComboDisplay()

func _on_combo_reset():
	Global.reset_combo()
	UpdateComboDisplay()

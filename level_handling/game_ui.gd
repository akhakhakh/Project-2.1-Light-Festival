extends Control

# Variables to store the total score and current combo count
var score: int = 0
var combo_count: int = 0

# Called once when the node enters the scene tree
func _ready():
	# Connect custom game signals to local functions
	# so the UI automatically updates when score or combo changes
	Signals.IncrementScore.connect(IncrementScore)
	Signals.IncrementCombo.connect(IncrementCombo)
	Signals.ResetCombo.connect(ResetCombo)
	
	# Reset combo when the game starts
	ResetCombo()

# Increases the score by a given amount
# 'incr' is the number of points to add
func IncrementScore(incr: int):
	score += incr
	# Update the score label text on the screen
	%ScoreLabel.text = " " + str(score) + " points"

# Increases the combo count when the player hits a note successfully
func IncrementCombo():
	combo_count += 1
	# Update the combo label text to show the current combo multiplier
	%ComboLabel.text = " " + str(combo_count) + "x combo"

# Resets the combo count (e.g., when the player misses a note)
func ResetCombo():
	combo_count = 0
	# Clear the combo label (hide combo when it's zero)
	%ComboLabel.text = ""

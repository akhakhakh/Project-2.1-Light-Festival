extends Sprite2D

# Preload scene references (these are external scenes used in the game)
@onready var falling_key = preload("res://objects/falling_key.tscn")     # The falling note prefab
@onready var score_text = preload("res://objects/score_press_text.tscn") # The floating score text prefab

# Key name that this object listens for (e.g., "button_Q")
@export var key_name: String = ""

# Queue to keep track of active falling notes assigned to this key
var falling_key_queue: Array = []

# --- Hit accuracy thresholds (measured in pixels from the target line) ---
const PERFECT_THRESHOLD := 30.0
const GREAT_THRESHOLD := 50.0
const GOOD_THRESHOLD := 60.0
const OK_THRESHOLD := 80.0

# --- Score values for each accuracy type ---
const PERFECT_SCORE := 250
const GREAT_SCORE := 100
const GOOD_SCORE := 50
const OK_SCORE := 20

# Player’s total score for this lane
var total_score: int = 0


# Called when the node enters the scene tree
func _ready():
	# Set up the glow overlay to match the correct frame
	$GlowOverlay.frame = frame + 4
	
	# Connect to global signal to spawn falling notes for this key
	Signals.CreateFallingKey.connect(CreateFallingKey)


# --- Handle input instantly (frame-independent) ---
func _input(event):
	# When the corresponding key is pressed, process the hit
	if event.is_action_pressed(key_name):
		HandleKeyPress()


# --- Main loop that checks for missed notes ---
func _process(_delta):
	# Only check if there are active notes
	if falling_key_queue.size() > 0:
		for fk in falling_key_queue:
			# If the falling key has passed the hit zone and wasn't hit
			if is_instance_valid(fk) and fk.has_passed:
				falling_key_queue.erase(fk)     # Remove from queue
				fk.queue_free()                 # Delete the node
				ShowScoreText("MISS", -20)      # Display "MISS" text
				Signals.ResetCombo.emit()       # Reset combo counter


# --- Function called when player presses the key ---
func HandleKeyPress():
	# If there are no notes in this lane, do nothing
	if falling_key_queue.is_empty():
		return

	var nearest_key = null      # The closest note to the hit line
	var min_distance = INF      # Start with an infinitely large distance

	# Find the nearest note to the hit position
	for fk in falling_key_queue:
		if not is_instance_valid(fk):
			continue
		var distance = abs(fk.pass_threshold - fk.global_position.y)
		if distance < min_distance:
			min_distance = distance
			nearest_key = fk

	# If no valid note found, stop
	if nearest_key == null:
		return

	# Play the key hit animation
	$AnimationPlayer.stop()
	$AnimationPlayer.play("key_hit")

	# Default values before accuracy check
	var text = "MISS"
	var points = 0

	# Determine hit accuracy based on distance from target line
	if min_distance < PERFECT_THRESHOLD:
		points = PERFECT_SCORE
		text = "PERFECT"
		Signals.IncrementCombo.emit()
	elif min_distance < GREAT_THRESHOLD:
		points = GREAT_SCORE
		text = "GREAT"
		Signals.IncrementCombo.emit()
	elif min_distance < GOOD_THRESHOLD:
		points = GOOD_SCORE
		text = "GOOD"
		Signals.IncrementCombo.emit()
	elif min_distance < OK_THRESHOLD:
		points = OK_SCORE
		text = "OK"
		Signals.IncrementCombo.emit()
	else:
		# Too far from the hit zone — count as a miss
		Signals.ResetCombo.emit()

	# Add earned points to the total score
	total_score += points
	print("Score:", total_score, "| Hit:", text, "| Distance:", min_distance)

	# Remove the hit note from the queue and the scene
	if is_instance_valid(nearest_key):
		falling_key_queue.erase(nearest_key)
		nearest_key.queue_free()

	# Show floating text (e.g., "PERFECT", "GOOD", etc.)
	ShowScoreText(text, -20)


# --- Spawns a falling note for this key lane ---
func CreateFallingKey(button_name: String):
	# Only create the note if it matches this key’s assigned name
	if button_name == key_name:
		var fk_inst = falling_key.instantiate()
		get_tree().get_root().call_deferred("add_child", fk_inst) # Add note to the scene tree safely
		fk_inst.Setup(position.x, frame + 4)                      # Position and initialize the note
		falling_key_queue.append(fk_inst)                         # Add to the active queue


# --- Displays score text above the key when a hit or miss occurs ---
func ShowScoreText(text: String, offset_y: int):
	var st_inst = score_text.instantiate()
	get_tree().get_root().call_deferred("add_child", st_inst)
	st_inst.SetTextInfo(text)                                    # Set text value (e.g., "GREAT")
	st_inst.global_position = global_position + Vector2(0, offset_y)

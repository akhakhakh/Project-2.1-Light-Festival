extends Sprite2D

# Preload scene references (these are external scenes used in the game)
@onready var falling_key = preload("res://rhythmgame_folder/rhythmgame_scenes/basic_level_scene/falling_key.tscn")     # The falling note prefab
@onready var score_text = preload("res://rhythmgame_folder/rhythmgame_scenes/basic_level_scene/score_press_text.tscn") # The floating score text prefab
@onready var glow_overlay: Sprite2D = $GlowOverlay

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

var _base_color: Color
var _is_popping: bool = false

# Called when the node enters the scene tree
func _ready():
	_base_color = modulate 
	# Set up the glow overlay to match the correct frame
	$GlowOverlay.frame = frame + 4
	
	# Start with glow invisible
	glow_overlay.modulate.a = 0.0
	
	# Connect to global signal to spawn falling notes for this key
	Signals.CreateFallingKey.connect(CreateFallingKey)
	
	#Add to group for easy access
	add_to_group("key_listeners")

func _circle_pop_effect() -> void:
	if _is_popping:
		return           

	_is_popping = true

	for i in range(3):
		modulate = Color(0.91, 0.577, 0.734, 0.988) 
		await get_tree().create_timer(0.03).timeout
		
		modulate = _base_color                   
		await get_tree().create_timer(0.03).timeout

	_is_popping = false

func _input(event):
	# When the corresponding key is pressed, process the hit
	if event.is_action_pressed(key_name):
		HandleKeyPress()

# --- Main loop that checks for missed notes ---
func _process(_delta):
	for i in range(falling_key_queue.size() - 1, -1, -1):
		var fk = falling_key_queue[i]
		
		# skip invalid or already handled notes
		if not is_instance_valid(fk):
			falling_key_queue.remove_at(i)
			continue
			
		if fk.has_passed and not fk.handled:
			fk.handled = true                      # mark immediately to prevent duplicates
			falling_key_queue.remove_at(i)
			fk.queue_free()
			
			ShowScoreText("MISS", -20)
			Signals.ResetCombo.emit()
			
			Global.miss_count += 1
			print("Miss count:", Global.miss_count)
			
			if Global.miss_count >= 5:
				GameOver()
			
				# Increase miss count globally
				Global.miss_count += 1
				print("Miss count:", Global.miss_count)

				# Check if player has 5 misses
				if Global.miss_count >= 100:
					GameOver()

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
	
	_circle_pop_effect()

	# Default values before accuracy check
	var text = "MISS"
	var points = 0

	# Determine hit accuracy based on distance from target line
	if min_distance < PERFECT_THRESHOLD:
		points = PERFECT_SCORE
		text = "PERFECT"
		Signals.IncrementCombo.emit()
		Signals.IncrementScore.emit(3) 
	elif min_distance < GREAT_THRESHOLD:
		points = GREAT_SCORE
		text = "GREAT"
		Signals.IncrementCombo.emit()
		Signals.IncrementScore.emit(3)
	elif min_distance < GOOD_THRESHOLD:
		points = GOOD_SCORE
		text = "GOOD"
		Signals.IncrementCombo.emit()
		Signals.IncrementScore.emit(2) 
	elif min_distance < OK_THRESHOLD:
		points = OK_SCORE
		text = "OK"
		Signals.IncrementCombo.emit()
		Signals.IncrementScore.emit(1) 
	else:
		# Too far from the hit zone — count as a miss
		Signals.ResetCombo.emit()

	# Add earned points to the total score
	total_score += points
	print("Score:", total_score, "| Hit:", text, "| Distance:", min_distance)

	# If we successfully hit a note, remove it AND mark it handled so it can't be counted as a miss
	if is_instance_valid(nearest_key):
		# Mark handled so the _process miss-check won't also count it
		nearest_key.handled = true
		# Remove from queue and free
		var idx = falling_key_queue.find(nearest_key)
		if idx != -1:
			falling_key_queue.remove_at(idx)
		nearest_key.queue_free()
			
	# Show floating text (e.g., "PERFECT", "GOOD", etc.)
	ShowScoreText(text, -20) 


# --- Spawns a falling note for this key lane ---
func CreateFallingKey(button_name: String):
	print("KeyListener ", key_name, " recieved ", button_name)
	# Only create the note if it matches this key’s assigned name
	if button_name == key_name:
		print("Match! Spawning note for: ", key_name)
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
	
	
func GameOver():
	print("GameOver called!")
	
	# Stop the music
	if has_node("/root/BeatManager"):
		print("BeatManager found")
		BeatManager.StopMusic()
	elif has_node("/root/BeatManagerJingleBells"):
		print("BeatManager_JingleBells found")
		BeatManagerJingleBells.StopMusic()
	else:
		print("BeatManager NOT found")
	
	# Save current score to global for display
	Global.total_score = total_score

	# Change to GameOver scene
	get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/endingScreen_scene/game_over.tscn")

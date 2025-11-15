extends Node2D

#Preload the Note Scene
var note_scene = preload("res://middle-arrows/assets/scenes/Note.tscn")

#Reference to nodes
@onready var notes_container = $NotesContainer 
@onready var hit_zone = $HitZone 
@onready var score_label = $UI/ScoreLabel
@onready var combo_label = $UI/ComboLabel
@onready var feedback_label = $UI/FeedbackLabel
@onready var music = $Music

#Game variable
var score = 0
var combo = 0
var game_started = false

#Timing variables
var bpm = 120
var beat_duration = 60.0 / bpm   #time between beats in seconds
var note_speed = 200.0  #pixels per second
var spawn_distance = 1200.0  #distance aboce hit zone

#Medium Mode beat pattern (in beats)
var beat_pattern = [ 0.0,    # Start
	4.0,    # 2 sec later
	8.0,    # 2 sec later
	12.0,   # 2 sec later
	16.0,   # 2 sec later
	20.0,   # 2 sec later
	24.0,   # 2 sec later
	28.0,   # 2 sec later
	30.0, 30.5, 31.0, 31.5, 32.0]
var current_beat_index = 0
var game_time = 0.0

func _ready():
	#set up UI
	score_label.text = "Score: 0"
	combo_label.text = "Combo : 0x"
	feedback_label.text = ""
	
	#Start game
	start_game()

func start_game():
	game_started = true
	score = 0
	combo = 0
	game_time = 0.0
	current_beat_index = 0
	update_ui()

func _process(delta):
	if not game_started:
		return
	
	game_time += delta
	
	#Spawn notes at the right time
	spawn_notes()
	
	#check for input
	if Input.is_action_just_pressed("hit_middle_note"):
		check_hit()

func spawn_notes():
	#check if we should spawn the next note
	if current_beat_index >= beat_pattern.size():
		return
	
	var next_beat_time = beat_pattern[current_beat_index] * beat_duration
	var spawn_time = next_beat_time - (spawn_distance / float(note_speed))
	
	if game_time >= spawn_time:
		create_note(next_beat_time)
		current_beat_index += 1

func create_note(target_time):
	var note = note_scene.instantiate()
	notes_container.add_child(note)
	
	#position the note above the hit zone
	note.position = Vector2(640, hit_zone.position.y - spawn_distance)
	
	#store the target time in the note 
	note.target_time = target_time
	note.speed = note_speed

func update_ui():
	score_label.text = "Score " + str(int(score))
	combo_label.text = "Combo " + str(combo) + "x" 

func hit_note(feedback, points, note):
	score += points * (1 + combo * 0.1) #combo multiplier
	combo += 1
	show_feedback(feedback)
	note.queue_free()
	update_ui()

func miss():
	combo = 0
	show_feedback("Miss!")
	update_ui()

func show_feedback(text):
	feedback_label.text = text
	feedback_label.modulate = Color.WHITE
	
	#SET COLOR  BASED ON FEEDBACK
	if "Perfect" in text:
		feedback_label.modulate = Color.YELLOW
	elif "Great" in text:
		feedback_label.modulate = Color.GREEN
	elif "Good" in text:
		feedback_label.modulate = Color.CYAN
	elif "Miss" in text:
		feedback_label.modulate = Color.RED
	
	#create a timer to clear feedback
	await get_tree().create_timer(4.0).timeout # stays 3 sec long
	feedback_label.text = ""

func check_hit():
	#find all notes in the hit zone
	var notes = notes_container.get_children()
	var closest_note = null
	var closest_distance = 999999
	
	for note in notes:
		var distance = abs(note.position.y - hit_zone.position.y)
		if distance < closest_distance:
			closest_distance = distance
			closest_note = note
	
	if closest_note == null or closest_distance > 150:
		miss()
		return
	
	#check accuracy based on distance
	if closest_distance < 40:
		hit_note("Perfect!", 100, closest_note)
	elif closest_distance < 70:
		hit_note("Great!", 75, closest_note)
	elif closest_distance < 100:
		hit_note("Good", 50, closest_note)
	elif closest_distance < 150:
		hit_note("OK", 25, closest_note)
	else:
		miss()
	

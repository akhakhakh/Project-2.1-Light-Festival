extends Node2D

#Preload the Note Scene
var note_scene = preload("res://middle-arrows/assets/scenes/Note.tscn")

#Reference to nodes
@onready var notes_container = $"NotesContainer (Node2D)"
@onready var hit_zone = $"HitZone (Area2D)"
@onready var score_label = $"UI (CanvasLayer)/ScoreLabel"
@onready var combo_label = $"UI (CanvasLayer)/ComboLabel"
@onready var feedback_label = $"UI (CanvasLayer)/FeedbackLabel"

#Game variable
var score = 0
var combo = 0
var game_started = false

#Timing variables
var bpm = 120
var beat_duration = 60.0 / bpm   #time between beats in seconds
var note_speed = 40  #pixels per second
var spawn_distance = 600  #distance aboce hit zone

#Easy Mode beat pattern (in beats)
var beat_pattern = [1,2,3,4.5,6,7,8,9.5,11,12,13,14.5,15,16,17,18,19.5]
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
	if Input.is_action_just_pressed("ui_accept") or Input.is_key_pressed(KEY_SPACE):
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
	score += points * (1 + combo + 0.1) #combo multiplier
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
	await get_tree().create_timer(0.3).timeout
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
	
	if closest_note == null:
		miss()
		return
	
	#check accuracy based on distance
	if closest_distance < 30:
		hit_note("Perfect!", 100, closest_note)
	elif closest_distance < 60:
		hit_note("Great!", 75, closest_note)
	elif closest_distance < 90:
		hit_note("Good", 50, closest_note)
	elif closest_distance < 120:
		hit_note("OK", 25, closest_note)
	else:
		miss()
	

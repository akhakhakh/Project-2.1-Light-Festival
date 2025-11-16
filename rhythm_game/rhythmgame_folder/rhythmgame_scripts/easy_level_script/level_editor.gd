extends Node2D

# Modes
const in_edit_mode: bool = false

# The name of the current level being played
var current_level_name = "RHYTHM_HELL"

# Time (in seconds) it takes for a falling key to reach the hit line after spawning
var fk_fall_time: float = 2.2

# Array to store recorded falling key timings when in edit mode
var fk_output_arr = [[], [], [], []]

# Level configuration data
var level_info = {
	"RHYTHM_HELL" : {
		# Music file for this level
		"music": load("res://rhythmgame_folder/rhythmgame_assets/music/Rhythm Hell.wav")
	}
}

# Called when the scene starts
func _ready():
	if in_edit_mode:
		# If editing, load and play music manually for recording
		$MusicPlayer.stream = level_info.get(current_level_name).get("music")
		$MusicPlayer.play()
		# Connect key press signals to record timing
		Signals.KeyListenerPress.connect(KeyListenerPress)
	else:
		# In play mode, BeatManager handles music playback
		# Just connect to BeatManager's spawn signal
		if has_node("/root/BeatManager"):
			# Connect directly to the autoloaded BeatManager
			var bm = get_node("/root/BeatManager")
			bm.connect("SpawnButton", Callable(self, "_on_spawn_button"))
			bm.StartMusic()
			print("BeatManager connected successfully!")
			
			# Start the music
			#BeatManager.StartMusic()
		else:
			print("ERROR: BeatManager not found! Check autoload settings.")

# Called when BeatManager wants to spawn a falling key - PLAY MODE
func _on_spawn_button(button_color: String) -> void:
	print("Spawn signal received for: ", button_color)
	
	# Convert color name to match KeyListener's expected format
	# BeatManager sends: "blue", "green", "red", "yellow"
	# KeyListener expects: "blue_button", "green_button", etc.
	var button_name = button_color + "_button"
	
	# Emit the signal to create the falling key
	Signals.CreateFallingKey.emit(button_name)

# Records key press time when in EDIT MODE
func KeyListenerPress(_button_name: String, array_num: int):
	# Save the current playback time adjusted by the fall delay
	var spawn_time = $MusicPlayer.get_playback_position() - fk_fall_time
	fk_output_arr[array_num].append(spawn_time)
	
# Called when the music finishes playing
func _on_music_player_finished():
	print("Song finished!")
	if in_edit_mode:
		print("Recorded timings: ", fk_output_arr)

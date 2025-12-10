extends Node2D

# Modes
const in_edit_mode: bool = false

# The name of the current level being played
var current_level_name = "DECK_THE_HALLS"

# Time (in seconds) it takes for a falling key to reach the hit line after spawning
var fk_fall_time: float = 1  # Faster fall time for 186 BPM

# Array to store recorded falling key timings when in edit mode
var fk_output_arr = [[], [], [], []]

# Level configuration data
var level_info = {
	"DECK_THE_HALLS" : {
		# Music file for this level
		"music": load("res://rhythmgame_folder/rhythmgame_assets/music/Deck The Halls Christmas.wav")
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
		# In play mode, BeatManager_JingleBells handles music playback
		# Connect to the BeatManager_JingleBells autoload
		if has_node("/root/BeatManagerMedium"):
			var bm = get_node("/root/BeatManagerMedium")
			bm.connect("SpawnButton", Callable(self, "_on_spawn_button"))
			
			#Connect to song finished signal
			if bm.has_signal("SongFinished"):
				bm.SongFinished.connect(_on_song_finished)
				
			bm.StartMusic()
			print("BeatManager_Medium connected successfully!")
		else:
			print("ERROR: BeatManager_Medium not found! Check autoload settings.")
			print("Add BeatManager_Medium.cs as an autoload in Project Settings")

# Called when BeatManager wants to spawn a falling key - PLAY MODE
func _on_spawn_button(button_color: String) -> void:
	print("Spawn signal received for: ", button_color)
	# Convert color name to match KeyListener's expected format
	# BeatManager sends: "blue", "green", "red", "yellow"
	# KeyListener expects: "blue_button", "green_button", etc.
	var button_name = button_color + "_button"
	
	# Emit the signal to create the falling key
	Signals.CreateFallingKey.emit(button_name)
	
#Called when song finishes	
func _on_song_finished():
	print("SONG FINISHED!")
	
	# Just use Global's values directly!
	print("\nFinal Results:")
	print("  Score: ", Global.total_score)
	print("  Misses: ", Global.miss_count)
	
	# Save song name (if you want to display it on results screen)
	Global.song_name = "Deck The Hall"
	
	# Wait for final notes
	await get_tree().create_timer(1.5).timeout
	
	# Go to results screen
	get_tree().change_scene_to_file("res://rhythmgame_folder/rhythmgame_scenes/win_menu/win_scene.tscn")


# Records key press time when in EDIT MODE
func KeyListenerPress(_button_name: String, array_num: int):
	#print(array_num)
	# Save the current playback time adjusted by the fall delay
	var spawn_time = $MusicPlayer.get_playback_position() - fk_fall_time
	fk_output_arr[array_num].append(spawn_time)
	
# Called when the music finishes playing
func _on_music_player_finished():
	print("Deck The Hall finished!")
	if in_edit_mode:
		print("Recorded timings: ", fk_output_arr)

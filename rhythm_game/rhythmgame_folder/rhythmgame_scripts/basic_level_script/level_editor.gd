extends Node2D

# Determines whether the game runs in edit (recording) mode or play mode
const in_edit_mode: bool = false

# The name of the current level being played
var current_level_name = "RHYTHM_HELL"

# Time (in seconds) it takes for a falling key to reach the hit line after spawning
var fk_fall_time: float = 2.2

# Array to store recorded falling key timings when in edit mode
var fk_output_arr = [[], [], [], []]

# Level configuration data
var level_info = {
	"RHYTHM_HELL" = {
		# List of spawn times for each lane (Q, W, E, R)
		"fk_times": "[[2.52533321380615, 6.55733375549316, 10.5573337554932, 14.5040004730225, 14.6533325195313, 15.5493324279785, 15.6986663818359, 15.9333332061768, 16.0719993591309, 19.76266746521, 22.8666675567627, 27.2293327331543, 30.823998260498, 34.5786674499512, 34.7173316955566, 35.0159996032715, 35.282666015625, 35.4640014648437, 35.6453330993652, 35.9333351135254, 36.1466682434082, 36.2533348083496, 36.3706672668457, 40.4133346557617], [3.03733329772949, 7.0586669921875, 7.28266696929932, 11.5600002288818, 11.8053329467773, 14.9200008392334, 15.0479991912842, 15.282666015625, 15.5813339233398, 16.296000289917, 18.8026664733887, 19.9119995117188, 20.0826671600342, 23.2080009460449, 23.346667098999, 23.9226673126221, 24.3279998779297, 26.792000579834, 27.7200000762939, 28.1253326416016, 31.1759994506836, 31.858666229248, 34.8453338623047, 34.9839981079102, 35.1546676635742, 35.3999984741211, 35.5706680297852, 35.741333770752, 35.8693321228027, 36.0186660766602, 36.1359985351562, 36.2533348083496], [3.56000022888184, 7.54933338165283, 10.7919996261597, 11.0266664505005, 14.5040004730225, 14.6533325195313, 15.5600002288818, 15.7093341827393, 15.9333332061768, 16.0826671600342, 19.0373332977295, 19.1973331451416, 19.3893325805664, 20.274666595459, 20.4026668548584, 23.5493324279785, 23.7093341827393, 24.1146667480469, 27.0159996032715, 27.9333332061768, 31.5280006408691, 32.231999206543], [4.07199983596802, 8.06133346557617, 12.0613334655762, 26.5893333435059, 27.4639995574951]]",
		
		# Music file for this level
		"music": load("res://rhythmgame_folder/rhythmgame_assets/music/Rhythm Hell.wav")
	}
}

# Called when the scene starts
func _ready():
	# Load and play the song for the current level
	$MusicPlayer.stream = level_info.get(current_level_name).get("music")
	$MusicPlayer.play()
	
	if in_edit_mode:
		# If editing, connect key press signals to record timing
		Signals.KeyListenerPress.connect(KeyListenerPress)
	else:
		# If not editing, get predefined falling key timings
		var fk_times = level_info.get(current_level_name).get("fk_times")
		var fk_times_arr = str_to_var(fk_times)
		
		var counter: int = 0
		# Loop through all lanes (Q, W, E, R)
		for key in fk_times_arr:
			
			var button_name: String = ""
			# Assign each array of times to a specific button/lane
			match counter:
				0:
					button_name = "button_Q"
				1:
					button_name = "button_W"
				2:
					button_name = "button_E"
				3:
					button_name = "button_R"
			
			# Schedule spawning of falling keys at the specified delays
			for delay in key:
				SpawnFallingKey(button_name, delay)
			
			counter += 1

# Records key press time when in edit mode
func KeyListenerPress(_button_name: String, array_num: int):
	# Save the current playback time adjusted by the fall delay
	fk_output_arr[array_num].append($MusicPlayer.get_playback_position() - fk_fall_time)

# Spawns a falling key after a delay
func SpawnFallingKey(button_name: String, delay: float):
	await get_tree().create_timer(delay).timeout
	Signals.CreateFallingKey.emit(button_name)

# Called when the music finishes playing
func _on_music_player_finished():
	print(fk_output_arr)  # Print recorded timings (used in edit mode)

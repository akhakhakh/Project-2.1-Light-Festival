extends Sprite2D

# Speeed at which the key falls down the screen
@export var fall_speed: float = 3.0
# Starting Y position for the falling key (off-screen at the top)
var init_y_pos: float = -360

# Used to check if the key has already passed the "perfect hit" zone
var has_passed: bool = false

# Whether this note has already been handled (hit or miss)
var handled: bool = false

# The Y position on the screen where the player should hit the key
var pass_threshold = 300.0

# Called when the node is created (before _ready)
func _init():
	# Disable processing by default — it starts moving only when set up
	set_process(false)
	
func _ready():
	# Automatically determine speed based on which BeatManager is present
	determine_speed_from_active_beat_manager()
	
func determine_speed_from_active_beat_manager():
	# Check which BeatManager is actually playing music
	# Check Jingle Bells BeatManager
	if has_node("/root/BeatManagerJingleBells"):
		var bm = get_node("/root/BeatManagerJingleBells")
		# Check if THIS BeatManager is actually running
		if is_beat_manager_active(bm):
			fall_speed = 4.0
			print("Active: Jingle Bells BeatManager - speed: 4.5")
			return
	
	# Check Medium BeatManager
	if has_node("/root/BeatManagerMedium"):
		var bm = get_node("/root/BeatManagerMedium")
		if is_beat_manager_active(bm):
			fall_speed = 2.5
			print("Active: Medium BeatManager - speed: 3.0")
			return
			
	# Check Easy BeatManager
	if has_node("/root/BeatManagerEasyLevel"):
		var bm = get_node("/root/BeatManagerEasyLevel")
		if is_beat_manager_active(bm):
			fall_speed = 2
			print("Active: Easy BeatManager - speed: 2")
			return
	
	# Default fallback
	fall_speed = 3.5
	print("No active BeatManager found")

func is_beat_manager_active(beat_manager) -> bool:
	# For C# BeatManager, check if music is playing
	# Try to access the music player child
	var music_player = null
	
	# Get the AudioStreamPlayer child
	for child in beat_manager.get_children():
		if child is AudioStreamPlayer:
			music_player = child
			break
	
	if music_player != null:
		# Check if this BeatManager's music is playing
		return music_player.playing
	
	return false

# Called every frame — this makes the key move down
func _process(_delta):
	# Move the key downward every frame
	
	global_position += Vector2(0, fall_speed)
	
	# When the key goes below the "hit" area and the timer is still running
	if global_position.y > pass_threshold and not $Timer.is_stopped() and not handled:
		# Stop the timer and mark that the key has passed
		# (used to detect misses)
		$Timer.stop()
		has_passed = true

# Called to prepare the falling key before it starts moving
func Setup(target_x: float, target_frame: int):
	# Set the key’s starting position (X and initial Y)
	global_position = Vector2(target_x, init_y_pos)
	
	# Set which arrow image/frame to use (for example: left, right, etc.)
	frame = target_frame
	# Start movementQQWEQW
# When the destroy timer finishes, remove the key from the scene
func _on_destroy_timer_timeout():
	queue_free()

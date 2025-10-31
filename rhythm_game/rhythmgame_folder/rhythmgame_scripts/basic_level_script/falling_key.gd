extends Sprite2D

# Speeed at which the key falls down the screen
@export var fall_speed: float = 3.5
# Starting Y position for the falling key (off-screen at the top)
var init_y_pos: float = -360

# Used to check if the key has already passed the "perfect hit" zone
var has_passed: bool = false

# The Y position on the screen where the player should hit the key
var pass_threshold = 300.0

# Called when the node is created (before _ready)
func _init():
	# Disable processing by default — it starts moving only when set up
	set_process(false)

# Called every frame — this makes the key move down
func _process(_delta):
	# Move the key downward every frame
	
	global_position += Vector2(0, fall_speed)
	
	# When the key goes below the "hit" area and the timer is still running
	if global_position.y > pass_threshold and not $Timer.is_stopped():
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

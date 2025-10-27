extends Node2D

@export var base_move_interval := 0.25   # Faster starting speed (was 0.35)
@export var grid_width := 7              # Number of columns
@export var grid_height := 11            # Number of rows
@export var starting_blocks := 3         # Initial block count
@export var speed_increase := 0.88       # Multiplier per row (lower = faster progression)
@export var first_block_loss_row := 5    # Row where player loses first block
@export var second_block_loss_row := 7   # Row where player loses second block

var locked_row_icons := []          
var markers := []
var icons := []
var cur_row := 10                        # Start at bottom (row 10)
var cur_left := 0                   
var cur_blocks := 3                 
var dir := 1                        
var moved := 0.0
var move_interval := base_move_interval
var is_row_active := true
var stack_history := []
var game_over := false
var max_blocks_available := 3            # Tracks maximum blocks available based on difficulty
var score: int = 0
var perfect_streak : int = 0
var score_multiplier: float = 1.0


func _ready():
	# Collect all marker positions
	var temp_markers = []
	for child in get_children():
		if child is Marker2D:
			temp_markers.append(child)
	
	# Sort markers: top to bottom (small Y to large Y), then left to right (small X to large X)
	temp_markers.sort_custom(func(a, b): 
		if abs(a.position.y - b.position.y) > 1:  # Different rows
			return a.position.y < b.position.y
		else:  # Same row
			return a.position.x < b.position.x
	)
	
	# Take only the first grid_width * grid_height markers (in case of duplicates)
	for i in range(min(grid_width * grid_height, temp_markers.size())):
		markers.append(temp_markers[i])
	
	print("Total markers loaded: ", markers.size())
	
	# Get the three icon sprites
	icons = [$Icon, $Icon2, $Icon3]
	reset_row()
	
func get_max_blocks_for_row(row: int) -> int:
	"""Calculate maximum blocks available based on current row"""
	# Convert row number to "height from bottom" (10 = 0, 9 = 1, etc.)
	var rows_from_bottom = 10 - row
	
	# Start with initial blocks
	var max_blocks = starting_blocks
	
	# Check if we've passed the first block loss threshold
	if rows_from_bottom >= (10 - first_block_loss_row):
		max_blocks -= 1
	
	# Check if we've passed the second block loss threshold
	if rows_from_bottom >= (10 - second_block_loss_row):
		max_blocks -= 1
	
	# Ensure we always have at least 1 block
	return max(1, max_blocks)

func reset_row():
	# Calculate maximum blocks available for this row
	max_blocks_available = get_max_blocks_for_row(cur_row)
	
	# Determine block count for this row
	if cur_row == 10:
		# First row (bottom): start with starting_blocks
		cur_blocks = starting_blocks
	elif stack_history.size() > 0:
		# Use the width from previous row, but cap it at max available
		var previous_count = stack_history[-1]["count"]
		cur_blocks = min(previous_count, max_blocks_available)
	else:
		cur_blocks = starting_blocks
	
	# Start from the left edge
	cur_left = 0
	dir = 1  # Start moving right
	is_row_active = true
	moved = 0.0
	
	# NEW SPEED CALCULATION - More aggressive exponential decrease
	# Calculate how many rows completed (0 at bottom, 10 at top)
	var rows_completed = 10 - cur_row
	
	# Use exponential formula: base_interval * (speed_increase ^ rows_completed)
	# This makes each row noticeably faster than the previous
	move_interval = base_move_interval * pow(speed_increase, rows_completed)
	
	# Apply ADDITIONAL multipliers at difficulty thresholds for dramatic speed boosts
	if cur_row <= second_block_loss_row:
		# At row 7 and above (counting from bottom), multiply speed significantly
		move_interval *= 0.65
	elif cur_row <= first_block_loss_row:
		# At row 5 and above, apply moderate speed boost
		move_interval *= 0.80
	
	# Ensure minimum speed cap for top rows (prevents going too slow)
	if cur_row <= 2:
		move_interval = min(move_interval, 0.08)  # Cap at very fast speed for top rows
	
	print("Row ", cur_row, " - Blocks: ", cur_blocks, " - Max Available: ", max_blocks_available, " - Speed: ", move_interval)
	
	update_icon_positions()

func update_icon_positions():
	# Show and position the active blocks
	for k in range(icons.size()):
		if k < cur_blocks:
			icons[k].show()
			set_icon_pos_by_positions(k, cur_row, cur_left + k)
		else:
			icons[k].hide()

func set_icon_pos_by_positions(i, row, col):
	# Calculate marker index: row * width + column
	var idx = row * grid_width + col
	if idx >= 0 and idx < markers.size():
		icons[i].global_position = markers[idx].global_position
	else:
		print("Warning: Invalid marker index ", idx)

func _process(delta):
	if game_over or !is_row_active:
		return
	
	moved += delta
	if moved >= move_interval:
		moved = 0.0
		move_row()

func move_row():
	# Move in current direction
	var next_left = cur_left + dir
	
	# Check boundaries and reverse if needed
	if next_left < 0:
		next_left = 0
		dir = 1
	elif next_left > grid_width - cur_blocks:
		next_left = grid_width - cur_blocks
		dir = -1
	
	cur_left = next_left
	update_icon_positions()

func _unhandled_input(event):
	if is_row_active and event.is_action_pressed("ui_down") and not game_over:
		stack_row()

func stack_row():
	is_row_active = false
	print("Stacking at row ", cur_row, " position ", cur_left)
	
	# Get current block positions
	var current_positions = []
	for j in range(cur_blocks):
		current_positions.append(cur_left + j)
	
	var surviving_positions = []
	
	# ARCADE STACKER LOGIC: Calculate overlap with previous row
	if stack_history.size() > 0:
		var prev_positions = stack_history[-1]["positions"]
		print("Previous positions: ", prev_positions)
		print("Current positions: ", current_positions)
		
		# Find overlapping blocks (survivors)
		for pos in current_positions:
			if pos in prev_positions:
				surviving_positions.append(pos)
		
		print("Surviving positions: ", surviving_positions)
		
		# --- Scoring logic ---
		var lost_blocks = cur_blocks - surviving_positions.size()
		
		if surviving_positions.size() == cur_blocks:
			# Perfect placement
			perfect_streak += 1
			
			# If 5 or more perfect in a row, activate 1.5x multiplier
			if perfect_streak >= 5:
				score_multiplier = 1.5
			else:
				score_multiplier = 1.0
			
			var points = int(1000 * score_multiplier)
			score += points
			print("Perfect placement! +" + str(points) + " points (x" + str(score_multiplier) + " multiplier)")
			
		elif surviving_positions.size() > 0 :
			# Imperfect (some lost, some survivied)
			perfect_streak = 0 # reset stack
			score_multiplier = 1.0
			
			var points = int((500 - lost_blocks * 250) * score_multiplier)
			score += points
			print("Imperfect placement! +" + str(points) + " points (-" + str(lost_blocks * 250) + " penalty)")
		
		else:
			# No overlap (game over handled later)
			print("No surviviors - Game Over!")
			end_game(false)
			return
		# --- End scoring logic ---

		# GAME OVER: No overlap at all
		if surviving_positions.size() == 0:
			print("No survivors - Game Over!")
			end_game(false)
			return
		
		# DIFFICULTY: Cap surviving blocks at max available for next row
		# This enforces block loss at specific rows
		if surviving_positions.size() > max_blocks_available:
			# Keep only the max allowed blocks (from the left side)
			surviving_positions = surviving_positions.slice(0, max_blocks_available)
			print("Blocks reduced to ", max_blocks_available, " due to difficulty cap")
	else:
		# First row: all blocks survive
		surviving_positions = current_positions
		print("First row - all blocks survive: ", surviving_positions)
	
	# Lock the surviving blocks visually
	for pos in surviving_positions:
		var icon_instance = icons[0].duplicate()
		var marker_idx = cur_row * grid_width + pos
		if marker_idx >= 0 and marker_idx < markers.size():
			icon_instance.global_position = markers[marker_idx].global_position
			icon_instance.show()
			add_child(icon_instance)
			locked_row_icons.append(icon_instance)
	
	# Hide moving icons
	for icon in icons:
		icon.hide()
	
	# Save this row to history
	stack_history.append({
		"positions": surviving_positions, 
		"count": surviving_positions.size()
	})
	
	# Check win condition (reached the top = row 0)
	if cur_row == 0:
		print("Reached top - You Win!")
		end_game(true)
		return 
	
	# Move to next row UP (decrease row number from 10 -> 0)
	cur_row -= 1
	print("Moving to row ", cur_row)
	
	# Safety check
	if cur_row < 0:
		end_game(true)
		return
	
	reset_row()

func end_game(win: bool) -> void:
	game_over = true

	# Hide all active icons
	for icon in icons:
		icon.hide()

	# Save the final score to the global singleton
	Global.score = score
	
	# Choose the correct scene
	var scene_path := "res://scenes/YouWon.tscn" if win else "res://scenes/GameOver.tscn"
	 
	# Replace the current scene safel
	get_tree().change_scene_to_file(scene_path)

extends Node2D

# ===== GAME CONFIGURATION =====
@export var base_move_interval := 0.4   # Starting speed in seconds (lower = faster)
@export var grid_width := 7              # Number of columns in the game grid
@export var grid_height := 21            # Number of rows in the game grid
@export var starting_blocks := 3         # How many blocks the player starts with
@export var speed_increase := 0.85       # Speed multiplier per row (lower = faster acceleration)
@export var bonus_message_duration := 2.0  # How long to show "BONUS SECTION" message
@export var points_popup_duration := 1.0   # How long to show the points popup

# ===== GAME STATE =====
var locked_row_icons := []          # All successfully stacked blocks
var markers := []                   # Grid positions where blocks can be placed
var icons := []                     # The 3 moving block icons
var cur_row := 20                   # Current row (20 = bottom, 0 = top)
var cur_left := 0                   # Leftmost position of moving blocks (0-6)
var cur_blocks := 3                 # Number of blocks currently moving
var dir := 1                        # Movement direction (1 = right, -1 = left)
var moved := 0.0                    # Timer for block movement
var move_interval := base_move_interval  # Current movement speed
var is_row_active := true           # Whether blocks are moving
var stack_history := []             # Previous stacks (positions and count)
var game_over := false              # Whether game has ended
var just_missed := false            # True if player just missed (penalty-only, no points)

# ===== SCORING =====
var score: int = 0                  # Player's total score
var perfect_streak : int = 0        # Consecutive perfect stacks
var score_multiplier: float = 1.0   # Streak bonus multiplier (1.5x at 5+ perfect)
var score_label: Label = null       # Score display label

# ===== BONUS SECTION =====
var bonus_label: Label = null           # "BONUS SECTION" text label
var bonus_message_shown := false        # Whether bonus message has been shown
var is_paused_for_bonus := false        # Whether game is paused for bonus message


func _ready():	
	var temp_markers = []
	for child in get_children():
		if child is Marker2D:
			temp_markers.append(child)
	
	# Sort markers: top to bottom, then left to right
	temp_markers.sort_custom(func(a, b): 
		if abs(a.position.y - b.position.y) > 1:
			return a.position.y < b.position.y
		else:
			return a.position.x < b.position.x
	)
	
	for i in range(min(grid_width * grid_height, temp_markers.size())):
		markers.append(temp_markers[i])
	
	print("Total markers loaded: ", markers.size())
	
	icons = [$Icon, $Icon2, $Icon3]
	
	# Create score display
	score_label = Label.new()
	score_label.position = Vector2(738, 380)
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.text = "0"
	add_child(score_label)
	
	# Create bonus message (hidden initially)
	bonus_label = Label.new()
	bonus_label.position = Vector2(350, 350)
	bonus_label.add_theme_font_size_override("font_size", 60)
	bonus_label.add_theme_color_override("font_color", Color(1, 1, 0))
	bonus_label.text = "BONUS AREA"
	bonus_label.visible = false
	add_child(bonus_label)
	
	reset_row()


func is_in_bonus_section(row: int) -> bool:
	# Bonus section is top 6 rows (rows 0-5)
	return row >= 0 and row <= 5


func show_bonus_message():
	# Pause game and show "BONUS SECTION" message for 2 seconds
	bonus_message_shown = true
	is_paused_for_bonus = true
	is_row_active = false
	bonus_label.visible = true
	print("Entering BONUS SECTION!")
	
	await get_tree().create_timer(bonus_message_duration).timeout
	
	bonus_label.visible = false
	is_paused_for_bonus = false
	is_row_active = true
	print("Bonus message finished, resuming game")


func show_points_popup(points: int, multiplier_text: String, _popup_pos: Vector2):
	# Create points label (green for positive, red for negative)
	var popup = Label.new()
	popup.position = position
	popup.add_theme_font_size_override("font_size", 36)
	
	if points >= 0:
		popup.add_theme_color_override("font_color", Color(0, 1, 0))
		popup.text = "+" + str(points)
	else:
		popup.add_theme_color_override("font_color", Color(1, 0, 0))
		popup.text = str(points)
	
	add_child(popup)
	
	# Create multiplier label if applicable
	var multiplier_label = null
	if multiplier_text != "":
		multiplier_label = Label.new()
		multiplier_label.position = Vector2(position.x + 80, position.y)
		multiplier_label.add_theme_font_size_override("font_size", 28)
		multiplier_label.add_theme_color_override("font_color", Color(1, 1, 0))
		multiplier_label.text = multiplier_text
		add_child(multiplier_label)
	
	animate_and_remove_popup(popup, multiplier_label)


func animate_and_remove_popup(popup: Label, multiplier_label: Label):
	# Animate popup moving up and fading out
	var tween = create_tween()
	tween.set_parallel(true)
	
	tween.tween_property(popup, "position:y", popup.position.y - 50, points_popup_duration)
	tween.tween_property(popup, "modulate:a", 0.0, points_popup_duration)
	
	if multiplier_label != null:
		tween.tween_property(multiplier_label, "position:y", multiplier_label.position.y - 50, points_popup_duration)
		tween.tween_property(multiplier_label, "modulate:a", 0.0, points_popup_duration)
	
	await tween.finished
	popup.queue_free()
	if multiplier_label != null:
		multiplier_label.queue_free()


func reset_row():
	# Determine block count for this row
	if cur_row == 20:
		cur_blocks = starting_blocks
	elif stack_history.size() > 0:
		var previous_count = stack_history[-1]["count"]
		cur_blocks = previous_count
	else:
		cur_blocks = starting_blocks
	
	# Reset position and movement
	cur_left = 0
	dir = 1
	is_row_active = true
	moved = 0.0
	
	# Calculate speed: faster with each completed row
	var rows_completed = 20 - cur_row
	move_interval = base_move_interval * pow(speed_increase, rows_completed)
	
	# Cap minimum speed so it doesn't get impossibly fast
	move_interval = max(move_interval, 0.08)
	
	var in_bonus = is_in_bonus_section(cur_row)
	print("Row ", cur_row, " - Blocks: ", cur_blocks, " - Speed: ", move_interval, " - Bonus: ", in_bonus)
	
	update_icon_positions()
	
	# Show bonus message when entering bonus section
	if is_in_bonus_section(cur_row) and not bonus_message_shown:
		show_bonus_message()


func update_icon_positions():
	for k in range(icons.size()):
		if k < cur_blocks:
			icons[k].show()
			set_icon_pos_by_positions(k, cur_row, cur_left + k)
		else:
			icons[k].hide()


func set_icon_pos_by_positions(i, row, col):
	# Convert row/column to marker array index
	var idx = row * grid_width + col
	
	if idx >= 0 and idx < markers.size():
		icons[i].global_position = markers[idx].global_position
	else:
		print("Warning: Invalid marker index ", idx)


func _process(delta):
	if game_over or !is_row_active or is_paused_for_bonus:
		return
	
	moved += delta
	if moved >= move_interval:
		moved = 0.0
		move_row()


func move_row():
	var next_left = cur_left + dir
	
	# Reverse direction at edges
	if next_left < 0:
		next_left = 0
		dir = 1
	elif next_left > grid_width - cur_blocks:
		next_left = grid_width - cur_blocks
		dir = -1
	
	cur_left = next_left
	update_icon_positions()


func _unhandled_input(event):
	if is_row_active and event.is_action_pressed("ui_down") and not game_over and not is_paused_for_bonus:
		stack_row()

<<<<<<< HEAD
func update_streak(is_perfect: bool):
	if is_perfect:
		perfect_streak += 1
	else:
		perfect_streak = 0

	print("Current streak: " + str(perfect_streak))
=======
>>>>>>> 5aea2229ac0b4534bf8d0c2069e95cc89312fdb3

func stack_row():
	is_row_active = false
	print("Stacking at row ", cur_row, " position ", cur_left)
	
	var current_positions = []
	for j in range(cur_blocks):
		current_positions.append(cur_left + j)
	
	var surviving_positions = []
	var popup_position = Vector2(450, 400)
	
	if stack_history.size() > 0:
		# Check overlap with previous row
		var prev_positions = stack_history[-1]["positions"]
		print("Previous positions: ", prev_positions)
		print("Current positions: ", current_positions)
		
		for pos in current_positions:
			if pos in prev_positions:
				surviving_positions.append(pos)
		
		print("Surviving positions: ", surviving_positions)
		
		var missed_blocks = cur_blocks - surviving_positions.size()
		
<<<<<<< HEAD
		if surviving_positions.size() == cur_blocks:
			# Perfect placement
			update_streak(true)
			
			
			
			# If 5 or more perfect in a row, activate 1.5x multiplier
			score_multiplier = 1.5 if perfect_streak >= 5 else 1.0
			
			var points = int(1000 * score_multiplier)
			score += points
			print("Perfect placement! +" + str(points) + " points (x" + str(score_multiplier) + " multiplier)")
			
		elif surviving_positions.size() > 0 :
			# Imperfect (some lost)
			update_streak(false)
			score_multiplier = 1.0
			
			var points = int((500 - lost_blocks * 250) * score_multiplier)
			score += points
			print("Imperfect placement! +" + str(points) + " points (-" + str(lost_blocks * 250) + " penalty)")
		
		else:
			# No overlap (game over handled later)
			print("No surviviors - Game Over!")
=======
		# Game over if missed 3 blocks
		if missed_blocks >= 3:
			print("Missed 3 blocks - Game Over!")
>>>>>>> 5aea2229ac0b4534bf8d0c2069e95cc89312fdb3
			end_game(false)
			return
		
		if surviving_positions.size() == 0:
			print("No surviving blocks - Game Over!")
			end_game(false)
			return
		
		var in_bonus = is_in_bonus_section(cur_row)
		var bonus_multiplier = 2.0 if in_bonus else 1.0
		
		if missed_blocks > 0:
			# Penalty only when missing blocks
			var penalty = missed_blocks * 35
			score = max(0, score - penalty)
			
			perfect_streak = 0
			score_multiplier = 1.0
			just_missed = true
			
			show_points_popup(-penalty, "", popup_position)
			print("Missed ", missed_blocks, " block(s)! -", penalty, " points")
			
		else:
			# Perfect stack or recovering from miss
			if just_missed:
				# Recovering: award normal points, restart streak
				just_missed = false
				perfect_streak = 1
				score_multiplier = 1.0
				
				var base_points = 0
				if surviving_positions.size() == 3:
					base_points = 500
				elif surviving_positions.size() == 2:
					base_points = 250
				elif surviving_positions.size() == 1:
					base_points = 100
				
				var final_points = int(base_points * bonus_multiplier)
				score += final_points
				
				var multiplier_text = ""
				if bonus_multiplier > 1.0:
					multiplier_text = "x" + str(bonus_multiplier)
				show_points_popup(final_points, multiplier_text, popup_position)
				
				print("Recovering! +", final_points, " points")
				
			else:
				# Perfect stack: continue streak
				perfect_streak += 1
				
				if perfect_streak >= 5:
					score_multiplier = 1.5
				else:
					score_multiplier = 1.0
				
				var base_points = 0
				if surviving_positions.size() == 3:
					base_points = 500
				elif surviving_positions.size() == 2:
					base_points = 250
				elif surviving_positions.size() == 1:
					base_points = 100
				
				var final_points = int(base_points * score_multiplier * bonus_multiplier)
				score += final_points
				
				var multiplier_text = ""
				if score_multiplier > 1.0 or bonus_multiplier > 1.0:
					var total_mult = score_multiplier * bonus_multiplier
					multiplier_text = "x" + str(total_mult)
				show_points_popup(final_points, multiplier_text, popup_position)
				
				print("Perfect! +", final_points, " points (streak: ", perfect_streak, ")")
		
		update_score_display()
		
	else:
		# First row
		surviving_positions = current_positions
		
		var in_bonus = is_in_bonus_section(cur_row)
		var bonus_multiplier = 2.0 if in_bonus else 1.0
		
		var points = int(500 * bonus_multiplier)
		score += points
		perfect_streak = 1
		just_missed = false
		
		var multiplier_text = ""
		if bonus_multiplier > 1.0:
			multiplier_text = "x" + str(bonus_multiplier)
		show_points_popup(points, multiplier_text, popup_position)
		
		print("First row stacked! +", points, " points")
		update_score_display()
	
	# Lock surviving blocks
	for pos in surviving_positions:
		var icon_instance = icons[0].duplicate()
		var marker_idx = cur_row * grid_width + pos
		
		if marker_idx >= 0 and marker_idx < markers.size():
			icon_instance.global_position = markers[marker_idx].global_position
			icon_instance.show()
			add_child(icon_instance)
			locked_row_icons.append(icon_instance)
	
	# Hide moving blocks
	for icon in icons:
		icon.hide()
	
	# Save to history
	stack_history.append({
		"positions": surviving_positions,
		"count": surviving_positions.size()
	})
	
	# Check win condition
	if cur_row == 0:
		print("Reached top - You Win!")
		end_game(true)
		return 
	
	# Move to next row
	cur_row -= 1
	print("Moving to row ", cur_row)
	
	if cur_row < 0:
		end_game(true)
		return
	
	reset_row()


func update_score_display():
	if score_label != null:
		score_label.text = str(score)


func end_game(win: bool) -> void:
	game_over = true

	for icon in icons:
		icon.hide()

	Global.score = score
	
	var scene_path := "res://scenes/YouWon.tscn" if win else "res://scenes/GameOver.tscn"
	get_tree().change_scene_to_file(scene_path)

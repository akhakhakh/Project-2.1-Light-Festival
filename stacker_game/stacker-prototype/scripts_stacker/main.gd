extends Node2D

# ===== GAME CONFIGURATION =====
@export var base_move_interval := 0.3   # Starting speed in seconds (lower = faster)
@export var grid_width := 7              # Number of columns in the game grid
@export var grid_height := 21            # Number of rows in the game grid
@export var starting_blocks := 3         # How many blocks the player starts with
@export var speed_increase := 0.90       # Speed multiplier per row (lower = faster acceleration)
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
var has_played_streak_sound = false # Checks and plays sound if you have a streak of 5 perfect stack
var row_start_time: float = 0.0
var speed_bonus_threshold: float = 2.0

# ===== BONUS SECTION =====
var bonus_label: Label = null           # "BONUS SECTION" text label
var bonus_message_shown := false        # Whether bonus message has been shown
var is_paused_for_bonus := false        # Whether game is paused for bonus message 
var bonus_area_rects := []
var is_in_bonus_zone := false
var bonus_label_tween: Tween = null

# ===== HIGH SCORE ======
var high_score_label: Label = null
var high_score_tween: Tween = null
var is_high_score := false

# ===== COUNTDOWN ======
var countdown_label: Label = null
var countdown_tween: Tween = null
var game_started := false

 
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
	
	# store the references to bonus area colorects
	for child in get_children():
		if child is ColorRect:
			if "Border" in child.name:
				bonus_area_rects.append(child)
				child.visible = false
	
	icons = [$Icon, $Icon2, $Icon3]
	
	var custom_font = load("res://assets_stacker/PixelifySans-VariableFont_wght.ttf")
	# Create score display
	score_label = Label.new()
	score_label.position = Vector2(760, 270)
	score_label.add_theme_font_override("font", custom_font)
	score_label.add_theme_font_size_override("font_size", 40)
	score_label.text = "0"
	add_child(score_label)
	
	# Create bonus message (hidden initially)
	bonus_label = Label.new()
	bonus_label.position = Vector2(370, 80)
	bonus_label.pivot_offset = Vector2(200, 39)
	bonus_label.add_theme_font_override("font", custom_font)
	bonus_label.add_theme_font_size_override("font_size", 60)
	bonus_label.add_theme_color_override("font_color", Color(1, 1, 0))
	bonus_label.text = "BONUS AREA"
	bonus_label.visible = false
	add_child(bonus_label)
	
	high_score_label = Label.new()
	high_score_label.position = Vector2(715, 300)
	high_score_label.pivot_offset = Vector2(250, 30)
	high_score_label.add_theme_font_override("font", custom_font)
	high_score_label.add_theme_font_size_override("font_size", 40)
	high_score_label.add_theme_color_override("font_color", Color(1, 0.84, 0))  # Gold color
	high_score_label.text = "NEW HIGH SCORE!"
	high_score_label.visible = false
	add_child(high_score_label)
	
	countdown_label = Label.new()
	countdown_label.position = Vector2(480, 300)
	countdown_label.size = Vector2(200, 150)
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.pivot_offset = Vector2(100, 75)
	countdown_label.add_theme_font_override("font", custom_font)
	countdown_label.add_theme_font_size_override("font_size", 120)
	countdown_label.add_theme_color_override("font_color", Color(0.0, 0.886, 0.949, 1.0))
	countdown_label.text = "3"
	countdown_label.visible = false
	add_child(countdown_label)
	
	reset_row()
	start_countdown()


func is_in_bonus_section(row: int) -> bool:
	# Bonus section is top 6 rows (rows 0-5)
	return row >= 0 and row <= 5


func show_bonus_message():
	# Pause game and show "BONUS SECTION" message for 2 seconds
	bonus_message_shown = true
	is_paused_for_bonus = true
	is_row_active = false
	bonus_label.visible = true
	print("Entering BONUS AREA!")
	
	activate_bonus_area_visuals()
	
	await get_tree().create_timer(bonus_message_duration).timeout
	
	is_paused_for_bonus = false
	is_row_active = true
	print("Bonus message finished, resuming game")


func activate_bonus_area_visuals():
	is_in_bonus_zone = true
	
	for rect in bonus_area_rects:
		rect.visible = true
		animate_rainbow_color(rect)
		
	start_bonus_label_pulse()


func animate_rainbow_color(rect: ColorRect):
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(rect, "color", Color.RED, 1.0)
	tween.tween_property(rect, "color", Color.YELLOW, 1.0)
	tween.tween_property(rect, "color", Color.GREEN, 1.0)
	tween.tween_property(rect, "color", Color.CYAN, 1.0)
	tween.tween_property(rect, "color", Color.BLUE, 1.0)
	tween.tween_property(rect, "color", Color.MAGENTA, 1.0)


func start_bonus_label_pulse():
	if bonus_label_tween:
		bonus_label_tween.kill()
	
	bonus_label_tween = create_tween()
	bonus_label_tween.set_loops()
	bonus_label_tween.tween_property(bonus_label, "scale", Vector2(1.2, 1.2), 0.8)
	bonus_label_tween.tween_property(bonus_label, "scale", Vector2(1.0, 1.0), 0.8)


func start_countdown():
	game_started = false
	is_row_active = false
	countdown_label.visible = true
	
	countdown_label.text = "3"
	countdown_label.scale = Vector2(1.0, 1.0)
	pulse_countdown_number()
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "2"
	countdown_label.scale = Vector2(1.0, 1.0)
	pulse_countdown_number()
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "1"
	countdown_label.scale = Vector2(1.0, 1.0)
	pulse_countdown_number()
	await get_tree().create_timer(1.0).timeout
	
	countdown_label.text = "GO!"
	countdown_label.scale = Vector2(1.0, 1.0)
	pulse_countdown_number()
	await get_tree().create_timer(0.8).timeout
	
	# Hide countdown and start game
	countdown_label.visible = false
	game_started = true
	is_row_active = true


func pulse_countdown_number():
	if countdown_tween:
		countdown_tween.kill()
	
	countdown_tween = create_tween()
	countdown_tween.tween_property(countdown_label, "scale", Vector2(1.3, 1.3), 0.4)
	countdown_tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.4)


func check_and_show_high_score():
	var leaderboard = LeaderboardManager.get_leaderboard()
	
	# Check if this would be a high score
	if leaderboard.size() == 0:
		is_high_score = true
	else:
		# Check if current score beats the #1 position
		if score > leaderboard[0]["score"]:
			is_high_score = true
	
	if is_high_score and not high_score_label.visible:
		high_score_label.visible = true
		
		# Start pulsing animation
		if high_score_tween:
			high_score_tween.kill()
		
		high_score_tween = create_tween()
		high_score_tween.set_loops()
		high_score_tween.tween_property(high_score_label, "scale", Vector2(1.2, 1.2), 0.8)
		high_score_tween.tween_property(high_score_label, "scale", Vector2(1.0, 1.0), 0.8)
		
		print("=== NEW HIGH SCORE! Current: ", score, " Previous best: ", leaderboard[0]["score"] if leaderboard.size() > 0 else 0)
		
		await get_tree().create_timer(3.0).timeout
		high_score_label.visible = false
		if high_score_tween:
			high_score_tween.kill()



func deactivate_bonus_area_visuals():
	is_in_bonus_zone = false
	
	for rect in bonus_area_rects:
		var tween = create_tween()
		tween.tween_property(rect, "color", Color.WHITE, 0.5)
	
	if bonus_label_tween:
		bonus_label_tween.kill()
		bonus_label.scale = Vector2(1.0, 1.0)
	
	bonus_label.visible = true


func show_points_popup(points: int, multiplier_text: String, _popup_pos: Vector2):
	# Create points label (green for positive, red for negative)
	var popup = Label.new()
	popup.position = _popup_pos
	
	var custom_font = load("res://assets_stacker/PixelifySans-VariableFont_wght.ttf")
	popup.add_theme_font_override("font", custom_font)
	popup.add_theme_font_size_override("font_size", 48)
	
	if points >= 0:
		popup.add_theme_color_override("font_color", Color.GREEN)
		popup.text = "+" + str(points)
	else:
		popup.add_theme_color_override("font_color", Color.RED)
		popup.text = str(points)
	
	add_child(popup)
	
	# Create multiplier label if applicable
	var multiplier_label = null
	if multiplier_text != "":
		multiplier_label = Label.new()
		multiplier_label.position =  popup.position + Vector2(120, 0)
		multiplier_label.add_theme_font_override("font", custom_font)
		multiplier_label.add_theme_font_size_override("font_size", 32)
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
	
	is_row_active = true
	moved = 0.0
	row_start_time = Time.get_ticks_msec() / 1000.0  # Starts the timer
	
	# Calculate speed: faster with each completed row
	var rows_from_bottom = 20 - cur_row
	move_interval = base_move_interval * pow(speed_increase, rows_from_bottom)
	
	var in_bonus = is_in_bonus_section(cur_row)
	if in_bonus:
		move_interval = move_interval / 1.5
		var bonus_rows_climbed = 5 - cur_row
		var bonus_acceleration = pow(0.90, bonus_rows_climbed)
		move_interval = move_interval * bonus_acceleration
	
	# Cap minimum speed so it doesn't get impossibly fast
	move_interval = max(move_interval, 0.04)
	
	print("Row ", cur_row, " - Blocks: ", cur_blocks, " - Speed: ", move_interval, " - Bonus: ", in_bonus)
	
	update_icon_positions()
	
	# Show bonus message when entering bonus section
	if is_in_bonus_section(cur_row) and not bonus_message_shown:
		show_bonus_message()
		
	if is_in_bonus_section(cur_row) and bonus_message_shown and not is_paused_for_bonus:
		bonus_label.visible = true
		if not is_in_bonus_zone:
			activate_bonus_area_visuals()
			
	if not is_in_bonus_section(cur_row) and is_in_bonus_zone:
		deactivate_bonus_area_visuals()


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
		
		if perfect_streak >= 5 and not has_played_streak_sound:
			$AudioPerfectStreak.play()
			has_played_streak_sound = true
		else:
			$AudioDrop.play()

func update_streak(is_perfect: bool):
	if is_perfect:
		perfect_streak += 1
		score_multiplier = 1.5 if perfect_streak >= 5 else 1.0
		if perfect_streak >= 5:
			print("1.5x multiplier active! (Streak:", perfect_streak, ")")
		else:
			score_multiplier = 1.0
			
	else:
		if perfect_streak > 0:
			print("Streak broken at " + str(perfect_streak) + " perfects.")
		perfect_streak = 0
		score_multiplier = 1.0
		has_played_streak_sound = false

	print("Current streak: " + str(perfect_streak))

func stack_row():
	is_row_active = false
	print("Stacking at row ", cur_row, " position ", cur_left)
	
	var current_positions = []
	for j in range(cur_blocks):
		current_positions.append(cur_left + j)
	
	var surviving_positions = []
	var popup_position = Vector2(725, 500)
	
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
		
		var lost_blocks = cur_blocks - surviving_positions.size()  
		
		if surviving_positions.size() == cur_blocks:
			update_streak(true)
			
			var points = int(1000 * score_multiplier)
			score += points
			print("Perfect placement! +" + str(points) + " points (x" + str(score_multiplier) + " multiplier)")
			
			# trigger the particles for each block in the row
			for i in range(cur_blocks):
				var icon = icons[i]
				if icon.has_node("CPUParticles2D"):
					var p = icon.get_node("CPUParticles2D")
					p.restart()
			
		elif surviving_positions.size() > 0 :
			update_streak(false)
			
			var points = int((500 - lost_blocks * 250) * score_multiplier)
			score += points
			print("Imperfect placement! +" + str(points) + " points (-" + str(lost_blocks * 250) + " penalty)")
		
		else:
			print("No surviviors - Game Over!")

		# Game over if missed 3 blocks
		if missed_blocks >= 3:
			print("Missed 3 blocks - Game Over!")
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
				var base_points = 0
				if surviving_positions.size() == 3:
					base_points = 500
				elif surviving_positions.size() == 2:
					base_points = 250
				elif surviving_positions.size() == 1:
					base_points = 100
				
				var stack_time = (Time.get_ticks_msec() / 1000.0) - row_start_time
				var speed_bonus = 0
				if stack_time < speed_bonus_threshold:
					speed_bonus = int((speed_bonus_threshold - stack_time) * 250)
				
				var final_points = int(base_points * score_multiplier * bonus_multiplier) + speed_bonus
				score += final_points
				
				if not is_high_score:
					check_and_show_high_score()
				
				var multiplier_text = ""
				if score_multiplier > 1.0 or bonus_multiplier > 1.0:
					var total_mult = score_multiplier * bonus_multiplier
					multiplier_text = "x" + str(total_mult)
					
					if speed_bonus > 0:
						if multiplier_text != "":
							multiplier_text += " +"
						else:
							multiplier_text = "+"
						multiplier_text += str(speed_bonus)
						
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
	
		# Trigger particles only on perfect stack
		if surviving_positions.size() == cur_blocks:
			if icon_instance.has_node("CPUParticles2D"):
				var p = icon_instance.get_node("CPUParticles2D")
				p.restart()
	
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
		
	LeaderboardManager.current_player_score = score
	Global.score = score
	
	if LeaderboardManager.current_player_name != "":
		if score > 0:
			LeaderboardManager.add_score(LeaderboardManager.current_player_name, score)
			print("Saved score for ", LeaderboardManager.current_player_name, ": ", score)
	
	var timer = get_tree().create_timer(0.2)
	await timer.timeout
	
# --- Show high score message ONLY at end ---
	if is_high_score:
		high_score_label.visible = true
	if high_score_tween:
		high_score_tween.kill()
	high_score_label.scale = Vector2(1.0, 1.0)
	high_score_tween = create_tween()
	high_score_tween.set_loops()
	high_score_tween.tween_property(high_score_label, "scale", Vector2(1.2, 1.2), 0.7)
	high_score_tween.tween_property(high_score_label, "scale", Vector2(1.0, 1.0), 0.7)


	
	var scene_path := "res://scenes_stacker/YouWon.tscn" if win else "res://scenes_stacker/GameOver.tscn"
	get_tree().change_scene_to_file(scene_path)

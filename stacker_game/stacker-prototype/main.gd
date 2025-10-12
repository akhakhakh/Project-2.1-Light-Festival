extends Node2D

@export var move_interval := 0.2    # Seconds between moves
@export var grid_width := 7         # Number of columns
@export var grid_height := 11       # Number of rows

var locked_row_icons := []          # Array to store icons for locked rows
var placed_blocks := []             # Array of arrays, each holds indices (columns) for placed blocks per row
var markers := []
var icons := []
var cur_row := grid_height - 1
var cur_left := 0                   # Leftmost marker index for the row
var cur_blocks := 3                 # Number of blocks left in row
var cur_positions = []              
var dir := 1                        # 1 = right, -1 = left
var moved := 0.0
var is_row_active := true
var stack_history := []
var game_over := false

func _ready():
	# Collect markers sorted row-major
	for child in get_children():
		if child is Marker2D:
			markers.append(child)
	markers.sort_custom(func(a, b): return a.position.y < b.position.y or (a.position.y == b.position.y and a.position.x < b.position.x))
	icons = [$Icon, $Icon2, $Icon3]
	reset_row()

func _compare_marker_pos(a, b):
	# Sort markers by (Y, X)
	if a.position.y == b.position.y:
		return a.position.x < b.position.x
	return a.position.y < b.position.y

func reset_row():
	if cur_row == grid_height - 1 or stack_history.size() == 0:
		cur_blocks = icons.size()
		cur_left = 0
	else:
		cur_blocks = stack_history[-1]["count"]
		cur_left = 0 # Always start the moving row from the leftmost column

	is_row_active = true
	moved = 0
	for k in range(icons.size()):
		if k < cur_blocks:
			icons[k].show()
			set_icon_pos_by_positions(k, cur_row, cur_left + k)
		else:
			icons[k].hide()

func set_icon_pos_by_positions(i, row, col):
	var idx = row * grid_width + col
	icons[i].global_position = markers[idx].global_position

func _process(delta):
	if game_over or !is_row_active:
		return
	moved += delta
	if moved > move_interval:
		moved = 0
		move_row()

func move_row():
	# Move left or right for the current block row
	if dir == 1 and cur_left + cur_blocks < grid_width:
		cur_left += 1
	elif dir == -1 and cur_left > 0:
		cur_left -= 1
	if cur_left == 0:
		dir = 1
	elif cur_left + cur_blocks == grid_width:
		dir = -1
	for k in range(cur_blocks):
		icons[k].show()
		set_icon_pos_by_positions(k, cur_row, cur_left + k)
	for k in range(cur_blocks, icons.size()):
		icons[k].hide()

func _unhandled_input(event):
	if is_row_active and event.is_action_pressed("ui_accept") and not game_over:
		stack_row()

func stack_row():
	is_row_active = false

	# List indices for blocks in the current row
	var block_indices = []
	for j in range(cur_blocks):
		block_indices.append(cur_left + j)

	# Compare with previous survivors, only keep individually aligned blocks
	if stack_history.size() > 0:
		var prev_positions = stack_history[-1]["positions"]
		var survivors = []
		for idx in block_indices:
			if idx in prev_positions:
				survivors.append(idx)
		if survivors.size() == 0:
			return end_game(false)
		block_indices = survivors

	# Visually lock icons for stacked row
	for j in range(block_indices.size()):
		var icon_instances = icons[j % icons.size()].duplicate()
		icon_instances.global_position = markers[cur_row * grid_width + block_indices[j]].global_position
		add_child(icon_instances)
		locked_row_icons.append(icon_instances)
	for icon in icons:
		icon.hide()

# Save only survivor columns for next round
	stack_history.append({"positions": block_indices, "count": cur_blocks})
	if cur_row == 0:
		return end_game(true)
	cur_row -= 1
	reset_row()

func end_game(win):
	game_over = true
	for icon in icons:
		icon.hide()
	print("You win!" if win else "Game Over!")

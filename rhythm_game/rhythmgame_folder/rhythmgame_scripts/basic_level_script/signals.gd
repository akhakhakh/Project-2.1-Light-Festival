extends Node2D

# --- SIGNAL DEFINITIONS ---

# Emitted when the player earns points.
# 'incr' is the number of points to add to the total score.
signal IncrementScore(incr: int)

# Emitted when the player hits a note successfully and the combo increases.
signal IncrementCombo()

# Emitted when the player misses a note, resetting the combo counter.
signal ResetCombo()

# Emitted to create (spawn) a new falling key for a specific button.
# 'button_name' indicates which key (e.g., Q, W, E, R) should spawn a note.
signal CreateFallingKey(button_name: String)

# Emitted when a player presses a key during gameplay.
# 'button_name' identifies which button was pressed,
# and 'array_num' tells which lane/column it belongs to.
signal KeyListenerPress(button_name: String, array_num: int)

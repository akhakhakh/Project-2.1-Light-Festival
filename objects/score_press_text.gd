extends Control

# Color codes for each score type:
# PERFECT → yellow (#ffbe00)
# GREAT   → light yellow (#e2dd25)
# GOOD    → light yellow (#a7dd25)
# OK      → light blue (#8dbfc7)
# MISS    → gray (#5a5758)

# Function to set the text and color of the score popup
func SetTextInfo(text: String):
	# Display the score text in the center of the label
	$ScoreLevelText.text = "[center]" + text
	
	# Change the text color depending on the type of hit
	match text:
		"PERFECT":
			# Yellow for perfect hits
			$ScoreLevelText.set("theme_override_colors/default_color", Color("ffbe00"))
		"GREAT":
			# Bright yellow for great hits
			$ScoreLevelText.set("theme_override_colors/default_color", Color("e2dd25"))
		"GOOD":
			# Same bright yellow for good hits
			$ScoreLevelText.set("theme_override_colors/default_color", Color("e2dd25"))
		"OK":
			# Light blue for okay hits
			$ScoreLevelText.set("theme_override_colors/default_color", Color("8dbfc7"))
		_:
			# Gray color for misses or any other text
			$ScoreLevelText.set("theme_override_colors/default_color", Color("5a5758"))

extends Button


func _ready() -> void:
	self.pressed.connect(_on_pressed)


func _process(delta: float) -> void:
	pass


func _on_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")

extends Node2D

@export var laser_scenes: Array[PackedScene] = []

var can_shoot = true

func _input(event):
	if Input.is_action_just_pressed("shoot") && can_shoot:
		can_shoot = false
		
		# Pick random laser scene
		var laser_scene = laser_scenes.pick_random()
		
		var laser = laser_scene.instantiate() as Area2D
		laser.global_position = get_parent().global_position - Vector2(0, 20)
		get_tree().root.get_node("main").add_child(laser)
		laser.tree_exited.connect(on_laser_destroyed)

func on_laser_destroyed():
	can_shoot = true

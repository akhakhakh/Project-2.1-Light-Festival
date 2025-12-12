extends Node2D

@export var laser_scene:PackedScene
@onready var shoot_sound = $AudioStreamPlayer2D
@export var fire_rate: float = 0.2 #seconds between shots

var can_shoot = true

func _input(event):
	if Input.is_action_just_pressed("shoot") && can_shoot:
		shoot_laser()
		can_shoot = false
		await get_tree().create_timer(fire_rate).timeout
		can_shoot = true

func shoot_laser():
		shoot_sound.play() #play sound effect
		var laser = laser_scene.instantiate() as Area2D
		laser.global_position = get_parent().global_position - Vector2(0, 20)
		get_tree().root.get_node("main").add_child(laser)
		#laser.tree_exited.connect(on_laser_destroyed)

func on_laser_destroyed():
	can_shoot = true

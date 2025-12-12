extends Area2D

class_name Ufo

@export var speed = 200
@onready var sprite = $Sprite2D
@onready var shooting_point = $ShootingPoint 
var explosion_texture = preload("res://spaceinvaders_assets/images/Ufo/Ufo-explosion.png")
var is_destroyed = false #flag 

func _process(delta):
	position.x -= delta * speed

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_area_entered(area):
	if area is Laser && !is_destroyed: #check if not already destroyed
		is_destroyed = true #set flag
		
		if shooting_point: #Check if shooting point exists before freeing
			shooting_point.queue_free()
		
		speed = 0
		sprite.texture = explosion_texture
		await get_tree().create_timer(1.5).timeout
		queue_free()

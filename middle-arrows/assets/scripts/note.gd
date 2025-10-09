extends Area2D

var speed = 400 #Pixels per second
var target_time = 0.0

func _ready():
	#Set up visual appearance if using ColorReact
	#customise in the scene editor instead
	pass

func _process(delta):
	#Move note downscroll
	position.y += speed * delta
	
	#Remove note if it goes too far past the hit zone
	if position.y > 800:
		queue_free()

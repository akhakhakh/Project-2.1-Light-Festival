extends Area2D

var speed = 400 #Pixels per second
var target_time = 0.0
var passed_hitzone = false # track if arrow passed without being hit

func _ready():
	#Set up visual appearance if using ColorReact
	#customise in the scene editor instead
	pass

func _process(delta):
	#Move note downscroll
	position.y += speed * delta
	
	# check if the arrow passed the hit zone without being hit
	if position.y > 650 and not passed_hitzone:
		passed_hitzone = true
		
		get_parent().get_parent().miss() #call miss() in main
	
	#Remove note if it goes too far past the hit zone
	if position.y > 800:
		queue_free()

extends PathFollow2D

onready var minecartSound = $Sprite/MinecartSound

var runSpeed = 150

func _ready():
	minecartSound.play()
	pass

func _process(delta):
	set_offset(get_offset()+runSpeed*delta)

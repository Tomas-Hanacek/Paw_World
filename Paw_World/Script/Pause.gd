extends Control
onready var game = $"../../"
onready var buttonResume = $StartButton

func _ready():
	buttonResume.grab_focus()
	pass

func _on_StartButton_pressed():
	game.pauseMenu()

func _on_QuitButton_pressed():
	get_tree().quit()

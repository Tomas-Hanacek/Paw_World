extends Control
onready var button=$StartButton

func _ready():
	$AudioStreamPlayer.play()
	button.grab_focus()
	pass

func _on_StartButton_pressed():
	get_tree().change_scene("res://Scene/Game.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()

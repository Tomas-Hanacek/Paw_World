extends Control
onready var restart = $VBoxContainer/RestartButton
onready var game = $"../../"

func _ready():
	pass

func _on_QuitButton_pressed():
	get_tree().quit()

func _on_RestartButton_pressed():
	get_tree().paused=false
	get_tree().reload_current_scene()

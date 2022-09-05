extends Control

# This is MenuScript

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	#pass # Replace with function body.
	$VBoxContainer/StartButton.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_StartButton_pressed():
	#print("Changing level")
	get_tree().change_scene("res://Levels/DemoLevel.tscn")

func _on_QuitButton_pressed():
	get_tree().quit()
	


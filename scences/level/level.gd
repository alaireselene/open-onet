extends Node2D

@onready var pause_menu = $pause_menu
var paused = false
var time_elapsed := 0
func _process(delta: float):
	if Input.is_action_just_pressed("pause"):
		pauseMenu()
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1 
	else:
		pause_menu.show()
		Engine.time_scale = 0
	
	paused = !paused
 
func _on_pause_menu_pressed():
	pauseMenu()
	


func _on_score_timer_timeout():
	time_elapsed += 1
	$UI/MarginContainer4/HBoxContainer/Time.text = str(time_elapsed)

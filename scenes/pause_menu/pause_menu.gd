extends Control

@onready var level = $"../"

func _on_continue_pressed():
	level.pauseMenu() # Replace with function body.


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_home_pressed():
	SceneHistory.go_to_scene("res://scenes/main_menu/main_menu.tscn") # Replace with function body.

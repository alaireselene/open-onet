extends Control

@onready var level = $"../"

func _on_continue_pressed():
	level.pauseMenu()

func _on_restart_pressed():
	Engine.time_scale = 1
	TimeManager.reset_time()
	get_tree().reload_current_scene()
	

func _on_home_pressed():
	level._on_main_menu_returned()
	SceneHistory.go_to_scene("res://scenes/main_menu/main_menu.tscn")

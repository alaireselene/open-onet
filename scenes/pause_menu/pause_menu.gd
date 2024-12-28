extends Control

@onready var level = $"../"

var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"

func _on_continue_pressed():
	level.pauseMenu()

func _on_restart_pressed():
	Engine.time_scale = 1
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	AudioPlayer.restart_music()
	get_tree().reload_current_scene()
	

func _on_home_pressed():
	
	level._on_main_menu_returned()
	SceneHistory.go_to_scene(main_menu_scene)
	#AudioPlayer.play_music_main_menu()

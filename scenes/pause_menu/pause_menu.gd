extends Control

@onready var level = $"../"
var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"

func _on_continue_pressed():
	level.pauseMenu()

func _on_restart_pressed():
	GameUtils.reset_game_state()
	get_tree().reload_current_scene()
	

func _on_home_pressed():	
	GameUtils.reset_game_state()
	SceneHistory.go_to_scene(main_menu_scene)
	#AudioPlayer.play_music_main_menu()

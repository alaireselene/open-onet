extends Control

@onready var Level = $"../"
func _on_resume_pressed():
	Level.pauseMenu()
	

func _on_main_menu_pressed():
	get_tree().change_scene_to_file("res://scences/main_menu.tscn")

extends Control

var current_level: int = 1

func _on_close_pressed():
	SceneHistory.go_back()

func _on_level_1_pressed() -> void:
	load_level(1)

func load_level(level: int) -> void:
	current_level = level
	# Store level data in SceneLoader before changing scene
	SceneLoader.store_param("current_level", level)
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

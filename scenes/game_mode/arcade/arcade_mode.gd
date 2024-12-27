extends Control

func _on_level_1_pressed() -> void:
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

func _on_exit_pressed() -> void:
	SceneHistory.go_back()

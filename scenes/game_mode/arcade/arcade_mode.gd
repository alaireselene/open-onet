extends Control


func _on_back_pressed():
	SceneHistory.go_back()


func _on_level_1_pressed() -> void:
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

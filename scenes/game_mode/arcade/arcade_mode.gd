extends Control

func _on_close_pressed():
	SceneHistory.go_back()

func _on_level_1_pressed() -> void:
	GameSettings.set_level(1)  # Thiết lập mức độ 1
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

func _on_level_2_pressed() -> void:
	GameSettings.set_level(2)  # Thiết lập mức độ 2
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

func _on_level_3_pressed() -> void:
	GameSettings.set_level(3)  # Thiết lập mức độ 3
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

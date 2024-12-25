extends Control


func _on_back_pressed():
	SceneHistory.go_back()


func _on_lv_1_pressed():
	SceneLoader.load_scene("res://scences/level.tscn")

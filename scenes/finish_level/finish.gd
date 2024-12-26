extends Control


func _on_home_pressed():
	SceneHistory.go_to_scene("res://scenes/main_menu/main_menu.tscn") # Replace with function body.


func _on_restart_pressed():
	get_tree().reload_current_scene()


func _on_next_level_pressed() -> void:
	pass # Replace with function body.

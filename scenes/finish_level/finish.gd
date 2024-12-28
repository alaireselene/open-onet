extends Control

@onready var level = "../"
@onready var finished_time = $Stats/Time/Label
func _on_home_pressed():
	level._on_main_menu_returned()
	SceneHistory.go_to_scene("res://scenes/main_menu/main_menu.tscn") # Replace with function body.


func _on_restart_pressed():
	Engine.time_scale = 1
	TimeManager.reset_time()
	get_tree().reload_current_scene()


func _on_next_level_pressed() -> void:
	pass # Replace with function body.


func _process(delta: float):
	TimeManager.finished_time(delta)
	update_countdown_label()


func update_countdown_label():
	var minutes = int(TimeManager.finished_time1/ 60)
	var seconds = int(int(TimeManager.finished_time1) % 60)
	finished_time.text = "%02d:%02d" % [minutes, seconds]

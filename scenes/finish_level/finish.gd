extends Control

@onready var level = $"../"
@onready var finished_time = $Stats/Time/Label
@onready var score_label = $"Score/Score Number"
@onready var highest_score_label = $"Stats/Best Score/Label" # Đường dẫn tới label highest_score

var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"

func _ready():
	pass

func _on_home_pressed():
	level._on_main_menu_returned()
	SceneHistory.go_to_scene(main_menu_scene) # Replace with function body.


func _on_restart_pressed():
	Engine.time_scale = 1
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	get_tree().reload_current_scene()
	
#	hàm trên có thể tối ưu bằng cách sử dụng _reset_game_state()


func _on_next_level_pressed() -> void:
	pass # Replace with function body.


func _process(delta: float):
	TimeManager.finished_time(delta)
	update_countdown_label()


func update_countdown_label():
	var minutes = int(TimeManager.finished_time1/ 60)
	var seconds = int(int(TimeManager.finished_time1) % 60)
	finished_time.text = "%02d:%02d" % [minutes, seconds]
# thiết kế lại	

func set_final_score(score: int):
	score_label.text = "%d" % score
	update_highest_score(score)

func update_highest_score(score : int):
	# So sánh và cập nhật highest_score
	if score > GameData.highest_score:
		GameData.highest_score = score
		print("New highest score:", GameData.highest_score)
	
	# Hiển thị điểm số cao nhất
	highest_score_label.text = "%d" % GameData.highest_score
	

extends Control

@onready var level = $"../"
@onready var finished_time = $Stats/Time/Label
@onready var score_label = $"Score/Score Number"
@onready var highest_score_label = $"Stats/Best Score/Label" # Đường dẫn tới label highest_score


var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"


func _ready():
	pass

func _on_home_pressed():
	GameUtils.reset_game_state()
	SceneHistory.go_to_scene(main_menu_scene) # Replace with function body.


func _on_restart_pressed():
	GameUtils.reset_game_state()
	get_tree().reload_current_scene()
	
#	hàm trên có thể tối ưu bằng cách sử dụng _reset_game_state()


func _on_next_level_pressed() -> void:
	GameSettings.current_level += 1
	if GameSettings.current_level <= 3:  # Chuyển sang màn tiếp theo
		GameSettings.set_level(GameSettings.current_level)
		SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")
	else:
		print("Không còn màn chơi")


func _process(delta: float):
	TimeManager.finished_time(delta)
	update_countdown_label()


func update_countdown_label():
	#var minutes = int(TimeManager.finished_time1/ 60)
	#var seconds = int(int(TimeManager.finished_time1) % 60)
	#finished_time.text = "%02d:%02d" % [minutes, seconds]
	finished_time.text = GameUtils.format_time(TimeManager.finished_time1)
# thiết kế lại	


func set_final_score(score: int):
	score_label.text = "%d" % score
	update_highest_score(score)


func update_highest_score(score : int):
	# So sánh và cập nhật highest_score
	if score > GameData.highest_score:
		GameData.highest_score = score
		GameData.save_data()
		print("New highest score:", GameData.highest_score)
	
	# Hiển thị điểm số cao nhất
	highest_score_label.text = "%d" % GameData.highest_score
	
	
	

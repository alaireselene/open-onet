extends Node2D

@onready var pause_menu = $PauseMenu
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
@onready var finish_scene = $Finish
@onready var score_label = $"Background/Left panel/Ultities/Score/Score number"


signal finished_time

func _ready():
	#set scale and position
	var scale = GameSettings.get_main_scale()
	var position = GameSettings.get_main_position()
	$Main.position = position  # Cập nhật vị trí của main
	$Main.scale = scale  # Cập nhật kích thước của main
	
	
	print("Scene reloaded or entered")
	
#	khi chuyển scene tải lại nhạc
	AudioPlayer.restart_music()
	AudioPlayer.play_music_level()
	
#	reset time
	TimeManager.reset_time()  # Đặt lại thời gian qua Singleton
	TimeManager.start_timer()  # Bắt đầu đếm thời gian
	update_countdown_label()  # Cập nhật giao diện
	

	var logic_match = get_node("LogicMatch")
	logic_match.connect("score_updated", Callable(self, "_on_score_updated"))
	#
	## Kết nối tín hiệu timeout từ TimeManager
	if not TimeManager.is_connected("timeout", Callable(self, "go_to_finish_scene")):
		TimeManager.connect("timeout", Callable(self, "go_to_finish_scene"))
#
	# Kết nối tín hiệu all_matched từ LogicMatch
	if not get_node("LogicMatch").is_connected("all_matched", Callable(self, "_on_all_matched")):
		get_node("LogicMatch").connect("all_matched", Callable(self, "_on_all_matched"))

	#var main = get_node("Main")
	#main.connect("score_updated", Callable(self, "_on_score_updated"))
	##
	### Kết nối tín hiệu timeout từ TimeManager
	#if not TimeManager.is_connected("timeout", Callable(self, "go_to_finish_scene")):
		#TimeManager.connect("timeout", Callable(self, "go_to_finish_scene"))
##
	## Kết nối tín hiệu all_matched từ LogicMatch
	#if not get_node("Main").is_connected("all_matched", Callable(self, "_on_all_matched")):
		#get_node("Main").connect("all_matched", Callable(self, "_on_all_matched"))




func _process(delta: float):
	# Cập nhật thời gian mỗi frame
	TimeManager.update_time(delta)
	update_countdown_label()
	
	# Xử lý tạm dừng
	if Input.is_action_just_pressed("ui_pause"):
		pauseMenu()


func pauseMenu():
	TimeManager.toggle_pause()
	Engine.time_scale = 0 if TimeManager.paused else 1
	if TimeManager.paused:
		AudioPlayer.pause_music()
		pause_menu.show()
	else:
		AudioPlayer.resume_music()
		pause_menu.hide()


func _on_pause_button_pressed():
	pauseMenu()

func update_countdown_label():
	var minutes = int(TimeManager.time_left / 60)
	var seconds = int(int(TimeManager.time_left) % 60)
	countdown_label.text = "%02d:%02d" % [minutes, seconds]

func go_to_finish_scene():	
	finish_scene.show()
	finish_scene.set_final_score(ScoreAlgorithms.score)
	
func _on_all_matched():
	TimeManager.stop_timer()  # Dừng đếm thời gian khi hoàn thành
	Engine.time_scale = 0
	go_to_finish_scene()

func reset_game_state():
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	Engine.time_scale = 1
	TimeManager.start_timer()
	update_countdown_label()


func _on_main_menu_returned():
	reset_game_state()

func _on_score_updated(new_score):
	score_label.text = "%d" % new_score

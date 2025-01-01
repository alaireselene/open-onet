extends Node2D

@onready var pause_menu = $PauseMenu
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
@onready var finish_scene = $Finish
@onready var score_label = $"Background/Left panel/Ultities/Score/Score number"



signal finished_time

func _ready():
	
	#set scale and position
	$Main.position = GameSettings.get_main_position()  # Cập nhật vị trí của main
	$Main.scale = GameSettings.get_main_scale() # Cập nhật kích thước của main
	
	print("Scene reloaded or entered")
	
#	khi chuyển scene tải lại nhạc
	#AudioPlayer.restart_music()
##	reset time
	#TimeManager.reset_time()  # Đặt lại thời gian qua Singleton
	#TimeManager.start_timer()  # Bắt đầu đếm thời gian
	
	#GameUtils.reset_game_state()
	#update_countdown_label()  # Cập nhật giao diện
	reset_game_state()

#	setting lại chỗ này cho tối ưu code
	var logic_match = get_node("LogicMatch")
	logic_match.connect("score_updated", Callable(self, "_on_score_updated"))
	#
	print(logic_match.get_class())

	## Kết nối tín hiệu timeout từ TimeManager
	if not TimeManager.is_connected("timeout", Callable(self, "go_to_finish_scene")):
		TimeManager.connect("timeout", Callable(self, "go_to_finish_scene"))
#
	# Kết nối tín hiệu all_matched từ LogicMatch
	if not logic_match.is_connected("all_matched", Callable(self, "_on_all_matched")):
		
		
		logic_match.connect("all_matched", Callable(self, "_on_all_matched"))

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
	countdown_label.text = GameUtils.format_time(TimeManager.time_left)

func go_to_finish_scene():	
	finish_scene.show()
	finish_scene.set_final_score(ScoreAlgorithms.score)


	
func _on_all_matched():
	TimeManager.stop_timer()  # Dừng đếm thời gian khi hoàn thành
	Engine.time_scale = 0
	go_to_finish_scene()



func reset_game_state():
	GameUtils.reset_game_state()
	update_countdown_label()


#func _on_main_menu_returned():
	#reset_game_state()

func _on_score_updated(new_score):
	print("score updated")
	score_label.text = "%d" % new_score
#hàm update_label có thể tối ưu

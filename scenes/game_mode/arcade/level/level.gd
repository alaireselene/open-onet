extends Node2D
@onready var pause_menu = $PauseMenu
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
@onready var finish_scene = $Finish
var paused = false
var time_left = 10 # 5 phút tính bằng giây
func _ready():
	
	$ScoreTimer.start() # Bắt đầu bộ đếm thời gian
	update_countdown_label() # Cập nhật giao diện ban đầu

func _process(delta: float):
	if Input.is_action_just_pressed("ui_pause"):
		pauseMenu()
		
func pauseMenu():
	if paused:
		pause_menu.hide()
		Engine.time_scale = 1 
	else:
		pause_menu.show()
		Engine.time_scale = 0
	paused = !paused
	
func _on_pause_button_pressed():
	pauseMenu()

func _on_score_timer_timeout():
	if not paused and time_left > 0:
		time_left -= 1
		update_countdown_label()
		if time_left <= 0:
			go_to_finish_scene()

func update_countdown_label():
	var minutes = int(time_left / 60)
	var seconds = int(time_left % 60)
	countdown_label.text = "%02d:%02d" % [minutes, seconds]

func go_to_finish_scene():
	finish_scene.show()

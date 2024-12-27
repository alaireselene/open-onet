extends Node2D
@onready var pause_menu = $PauseMenu
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
@onready var score_label = $"Background/Left panel/Ultities/Score/Score number"
@onready var health_label = $"Background/Left panel/Ultities/Score/Health/Health number"
@onready var finish_scene = $Finish

var paused = false
var time_left = 10 # 5 phút tính bằng giây
var current_score = 0
var current_health = 5
var last_update = 0

func _ready():
	print("Scene reloaded")
	$ScoreTimer.start() # Bắt đầu bộ đếm thời gian
	update_countdown_label() # Cập nhật giao diện ban đầu

func _process(delta: float):
	if Input.is_action_just_pressed("ui_pause"):
		pauseMenu()
		
# Display pause menu
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

# Display finish popup
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
	
# Update health label
func update_health_label():
	health_label.text = "x%d" % current_health
	
# Update score
func update_score_label():
	score_label.text = "%06d" % current_score
	

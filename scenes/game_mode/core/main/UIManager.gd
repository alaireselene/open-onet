extends Node

class_name UIManager

# References to UI elements
@onready var score_label = $"Background/Left panel/Ultities/Score/Score number"
@onready var health_label = $"Background/Left panel/Ultities/Score/Health/Health number"
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
@onready var pause_menu = $PauseMenu
@onready var finish_scene = $Finish

# Signals
signal pause_toggled(paused: bool)
signal level_finished(final_score: int)

func _ready() -> void:
    pause_menu.hide()
    finish_scene.hide()

func update_countdown(time_left: float) -> void:
    var minutes = int(time_left / 60)
    var seconds = int(time_left) % 60
    countdown_label.text = "%02d:%02d" % [minutes, seconds]

func update_score(new_score: int) -> void:
    score_label.text = "%06d" % new_score

func update_health(health: int) -> void:
    health_label.text = "x%d" % health

func show_pause_menu(show: bool) -> void:
    if show:
        pause_menu.show()
    else:
        pause_menu.hide()

func show_finish_scene(final_score: int) -> void:
    finish_scene.show()
    finish_scene.set_final_score(final_score)
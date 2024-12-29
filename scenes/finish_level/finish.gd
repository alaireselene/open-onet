extends Control

@onready var level = $"../"
@onready var finished_time_label = $Stats/Time/Label
@onready var score_label = $"Score/Score Number"
@onready var highest_score_label = $"Stats/Best Score/Label"

var main_menu_scene = "res://scenes/main_menu/main_menu.tscn"
var elapsed_time: float = 0.0

func _ready():
    if TimeManager and TimeManager.has_signal("timeout"):
        TimeManager.timeout.connect(_on_time_finished)
    update_labels()

func _on_home_pressed():
    level._on_main_menu_returned()
    SceneHistory.go_to_scene(main_menu_scene)

func _on_restart_pressed():
    Engine.time_scale = 1
    TimeManager.reset_time()
    ScoreAlgorithms.reset_score()
    get_tree().reload_current_scene()

func _on_next_level_pressed() -> void:
    pass

func _process(delta: float):
    elapsed_time += delta
    update_countdown_label()

func update_countdown_label():
    var minutes = int(elapsed_time / 60)
    var seconds = int(elapsed_time) % 60
    finished_time_label.text = "%02d:%02d" % [minutes, seconds]

func update_labels():
    set_final_score(ScoreAlgorithms.score)
    update_highest_score(ScoreAlgorithms.score)

func set_final_score(score: int):
    score_label.text = str(score)
    update_highest_score(score)

func update_highest_score(score: int):
    if score > GameData.highest_score:
        GameData.highest_score = score
        print("New highest score:", GameData.highest_score)
    highest_score_label.text = str(GameData.highest_score)

func _on_time_finished() -> void:
    print_debug("Time finished")
    update_labels()


extends Node2D
## Level scene controller that manages game state, UI and player interactions.
##
## Handles game state loading/saving, UI updates, pause functionality,
## and coordinates between TimeManager, ScoreAlgorithms and GameData.
## Also manages scene transitions and health system.
##

## Reference to pause menu overlay
@onready var pause_menu = $PauseMenu
## Reference to countdown timer label
@onready var countdown_label = $"Background/Left panel/Time left/Countdown"
## Reference to game finish overlay
@onready var finish_scene = $Finish
## Reference to score display label
@onready var score_label = $"Background/Left panel/Ultities/Score/Score number"

## Emitted when level time is finished
signal finished_time

## Initializes level state and UI
## Loads saved game if available or starts new game
## Connects necessary signals and updates UI elements
func _ready():
	print("Scene reloaded or entered")

	# Get reference to Main node
	var main_node = get_node("Main")

	# 1. Reset engine and music
	Engine.time_scale = 1
	AudioPlayer.restart_music()
	AudioPlayer.play_music_level()

	# 4. Then check for valid saved game
	if GameData.load_game() and GameData.game_data.time_left > 0:
		print("Loading saved game in progress")
		TimeManager.time_left = GameData.game_data.time_left
		ScoreAlgorithms.score = GameData.game_data.current_score
		ScoreAlgorithms.chain_count = GameData.game_data.chain_count
		if main_node and GameData.game_data.grid_state:
			main_node.grid_data = GameData.game_data.grid_state
			main_node.refresh_grid()
		TimeManager.start_timer()
	else:
		print("Starting new game")
		# Init new game state
		TimeManager.reset_time()
		ScoreAlgorithms.reset_score()
		if GameData.current_health > 0:
			GameData.current_health -= 1
			TimeManager.start_timer()
			GameData.save_game()
		else:
			# Handle no health remaining
			print("No health remaining!")
			go_to_finish_scene()
			return

	# Update UI
	update_countdown_label() 
	update_health_display()
	update_score_display()
	
	# Connect signals
	main_node.connect("score_updated", Callable(self, "_on_score_updated"))
	
	# Kết nối tín hiệu timeout từ TimeManager
	if not TimeManager.is_connected("timeout", Callable(self, "go_to_finish_scene")):
		TimeManager.connect("timeout", Callable(self, "go_to_finish_scene"))

	# Kết nối tín hiệu all_matched từ Main
	if not main_node.is_connected("all_matched", Callable(self, "_on_all_matched")):
		main_node.connect("all_matched", Callable(self, "_on_all_matched"))

## Process frame update
## Updates timer, saves game state during active gameplay
## Handles pause input
func _process(delta: float):
	if TimeManager.time_left > 0:
		TimeManager.update_time(delta)
		update_countdown_label()
		# Only save during active gameplay
		if not TimeManager.paused:
			GameData.save_game()
	
	# Xử lý tạm dừng
	if Input.is_action_just_pressed("ui_pause"):
		pauseMenu()

## Toggles pause state
## Handles UI visibility and audio
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

## Updates countdown display
## Formats time as MM:SS
func update_countdown_label():
	var minutes = int(TimeManager.time_left / 60)
	var seconds = int(int(TimeManager.time_left) % 60)
	countdown_label.text = "%02d:%02d" % [minutes, seconds]

## Shows finish scene with final score
func go_to_finish_scene():	
	finish_scene.show()
	finish_scene.set_final_score(ScoreAlgorithms.score)

## Called when all tiles are matched
## Stops timer and saves final state
func _on_all_matched():
	TimeManager.stop_timer()  # Dừng đếm thời gian khi hoàn thành
	Engine.time_scale = 0
	GameData.current_health -= 1
	GameData.save_game()
	go_to_finish_scene()

## Resets game state for new game
## Resets timer, score and updates UI
func reset_game_state():
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	Engine.time_scale = 1
	TimeManager.start_timer()
	update_countdown_label()

func _on_main_menu_returned():
	reset_game_state()

## Updates score display
## @param new_score Current game score
func _on_score_updated(new_score):
	score_label.text = "%d" % new_score

## Updates health display
## Shows current health count with 'x' prefix
func update_health_display():
	var health_label = $"Background/Left panel/Ultities/Score/Health/Health number"
	health_label.text = "x%d" % GameData.current_health

## Updates score display
## Shows current score value
func update_score_display():
	score_label.text = "%d" % ScoreAlgorithms.score

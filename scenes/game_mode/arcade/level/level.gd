extends Node2D
## Level scene controller that manages game state, UI and player interactions.
##
## Handles game state loading/saving, UI updates, pause functionality,
## and coordinates between TimeManager, ScoreAlgorithms and GameData.
## Also manages scene transitions and health system.
##

# Make UI Manager optional with a warning if it's missing
@export var ui_manager: UIManager

# Managers and Modules
@onready var main_game = $Main
@onready var time_manager = $TimeManager
@onready var game_data: GameDataManager = $"/root/GameData"
@onready var level_data = preload("res://scenes/game_mode/core/main/LevelData.gd").new()
@onready var health_manager = $HealthManager

# Signals
signal finished_time

## Initializes level state and UI
## Loads saved game if available or starts new game
## Connects necessary signals and updates UI elements
func _ready():
	print_debug("Scene reloaded or entered")

	# Verify UIManager exists
	if not ui_manager:
		push_warning("UIManager not found in Level scene. Attempting to find by node path...")
		ui_manager = $UIManager
		if not ui_manager:
			push_error("UIManager not found. Please add UIManager node to Level scene.")
			return

	# Load level data
	var current_level = game_data.current_level
	if level_data.load_level(current_level):
		print_debug("Level loaded successfully")
	else:
		push_error("Failed to load level data for level %d" % current_level)
		return

	# Reset engine and music
	Engine.time_scale = 1
	AudioPlayer.restart_music()
	AudioPlayer.play_music_level()

	# Load or initialize game state
	if game_data.load_game() and game_data.game_data.time_left > 0:
		print_debug("Loading saved game in progress")
		time_manager.time_left = game_data.game_data.time_left
		score_algorithms.score = game_data.game_data.current_score
		score_algorithms.chain_count = game_data.game_data.chain_count
		if main_game and game_data.game_data.grid_state:
			main_game.grid_data = game_data.game_data.grid_state
			main_game.refresh_grid()
		time_manager.start_timer()
	else:
		print_debug("Starting new game")
		initialize_new_game()

	# Update UI
	ui_manager.update_countdown(time_manager.time_left)
	ui_manager.update_score(score_algorithms.score)
	ui_manager.update_health(game_data.current_health)
	
	# Connect signals only if UIManager exists
	if ui_manager:
		main_game.score_updated.connect(ui_manager.update_score)
		main_game._on_all_matched.connect(_on_level_complete)
		time_manager.timeout.connect(_on_time_up)
		time_manager.time_updated.connect(ui_manager.update_countdown)

	# Connect health manager signals
	health_manager.health_updated.connect(_on_health_updated)

	# Connect pause menu signals
	ui_manager.pause_menu.pressed.connect(_on_pause_button_pressed)

	# Load level data from SceneLoader parameters
	var params = SceneLoader.get_params()
	if params and params.has("level_data"):
		load_level_data(params.level_data)

## Initializes new game state
func initialize_new_game():
	time_manager.reset_time()
	score_algorithms.reset_score()
	if game_data.current_health > 0:
		game_data.decrement_health()
		time_manager.start_timer()
		game_data.save_game()
	else:
		print_debug("No health remaining")
		go_to_finish_scene()
	
## Process frame update
## Updates timer and handles pause input
func _process(delta: float):
	if time_manager.time_left > 0:
		time_manager.update_time(delta)
		ui_manager.update_countdown(time_manager.time_left)

		# Only save during active gameplay
		if not time_manager.paused:
			game_data.save_game()
	
	# Handle pause input
	if Input.is_action_just_pressed("ui_pause"):
		toggle_pause()

## Toggles pause state
## Handles UI visibility and audio
func toggle_pause():
	time_manager.toggle_pause()
	Engine.time_scale = 0 if time_manager.paused else 1
	ui_manager.show_pause_menu(time_manager.paused)

	if time_manager.paused:
		AudioPlayer.pause_music()
	else:
		AudioPlayer.resume_music()

## Shows finish scene with final score
func go_to_finish_scene():	
	ui_manager.show_finish_scene(score_algorithms.score)
	Engine.time_scale = 0

## Called when all tiles are matched
func _on_all_matched():
	time_manager.stop_timer()
	Engine.time_scale = 0
	game_data.decrement_health()
	game_data.save_game()
	go_to_finish_scene()

## Resets game state for new game
func reset_game_state():
	time_manager.reset_time()
	score_algorithms.reset_score()
	Engine.time_scale = 1
	time_manager.start_timer()
	ui_manager.update_countdown(time_manager.time_left)
	ui_manager.update_health(game_data.current_health)
	ui_manager.update_score(score_algorithms.score)

## Updates score display
func _on_score_updated(new_score: int):
	if ui_manager:
		ui_manager.update_score(new_score)	

## Handle returning to main menu
func _on_main_menu_returned():
	reset_game_state()

## Handle health updates
func _on_health_updated(current_health: int):
	ui_manager.update_health(current_health)
	if current_health <= 0:
		go_to_finish_scene()

## Handle pause button press
func _on_pause_button_pressed() -> void:
	toggle_pause()

## Load level data from file
func load_level_data(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json = JSON.new()
		var parse_result = json.parse(file.get_as_text())
		if parse_result == OK:
			var level_data = json.get_data()
			setup_level(level_data)
		file.close()

## Setup level based on loaded data
func setup_level(data: Dictionary) -> void:
	# Configure level based on loaded data
	if data.has("grid"):
		generate_grid(data.grid)
	if data.has("time"):
		time_manager.time_left = data.time
	if data.has("target_score"):
		score_algorithms.target_score = data.target_score

## Generate grid based on loaded data
func generate_grid(grid_data: Array) -> void:
	if main_game:
		main_game.grid_data = grid_data
		main_game.refresh_grid()

## Handle time up event
func _on_time_up() -> void:
	main_game.can_play = false
	if ui_manager:
		ui_manager.show_finish_scene(main_game.current_score)

## Handle level complete event
func _on_level_complete() -> void:
	time_manager.stop_timer()
	main_game.can_play = false
	if ui_manager:
		ui_manager.show_finish_scene(main_game.current_score)

## Handle pause button press
func _on_pause_pressed() -> void:
	if ui_manager:
		var is_paused = time_manager.toggle_pause()
		ui_manager.show_pause_menu(is_paused)

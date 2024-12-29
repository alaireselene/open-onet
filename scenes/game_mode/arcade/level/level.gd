extends Node2D
## Level scene controller that manages game state, UI and player interactions.
##
## Handles game state loading/saving, UI updates, pause functionality,
## and coordinates between TimeManager, ScoreAlgorithms and GameData.
## Also manages scene transitions and health system.
##

# Reference to UIManager
@onready var ui_manager = $UIManager

# Managers and Modules
@onready var main_node = $Main
@onready var time_manager = %TimeManager
@onready var score_algorithms = %ScoreAlgorithms
@onready var game_data = %GameData
@onready var level_data = preload("res://scenes/game_mode/core/main/LevelData.gd").new()
@onready var health_manager = $HealthManager

# Signals
signal finished_time

## Initializes level state and UI
## Loads saved game if available or starts new game
## Connects necessary signals and updates UI elements
func _ready():
	print_debug("Scene reloaded or entered")

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
		if main_node and game_data.game_data.grid_state:
			main_node.grid_data = game_data.game_data.grid_state
			main_node.refresh_grid()
		time_manager.start_timer()
	else:
		print_debug("Starting new game")
		initialize_new_game()

	# Update UI
	ui_manager.update_countdown(time_manager.time_left)
	ui_manager.update_score(score_algorithms.score)
	ui_manager.update_health(game_data.current_health)
	
	# Connect signals
	if not main_node.score_updated.is_connected(_on_score_updated):
		main_node.score_updated.connect(_on_score_updated)

	if not time_manager.timeout.is_connected(go_to_finish_scene):
		time_manager.timeout.connect(go_to_finish_scene)

	if not main_node.all_matched.is_connected(_on_all_matched):
		main_node.all_matched.connect(_on_all_matched)

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
	if main_node:
		main_node.grid_data = grid_data
		main_node.refresh_grid()

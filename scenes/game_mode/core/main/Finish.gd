extends Control  # Ensure the correct node type is extended

@export var game_data: GameDataManager  # Export to allow assignment in Inspector

# UI References
@onready var score_label = $ScoreValue
@onready var high_score_label = $HighScoreValue

var current_level: int = 1

func _ready() -> void:
	if not game_data:
		game_data = get_node("/root/GameData")  # Fallback to get singleton if not set in Inspector

func _on_close_pressed():
	SceneHistory.go_back()

func _on_level_1_pressed() -> void:
	load_level(1)

func load_level(level: int) -> void:
	current_level = level
	# Store level data in SceneLoader before changing scene
	SceneLoader.store_param("current_level", level)
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")

func update_highest_score(current_score: int) -> void:
	if current_score > game_data.game_data.highest_score:
		game_data.game_data.highest_score = current_score
		game_data.save_game()
		print("New Highest Score: ", current_score)

func _on_level_complete(current_score: int) -> void:
	update_highest_score(current_score)

func set_final_score(score: int) -> void:
	score_label.text = str(score)
	
	# Update highest score if necessary
	if score > game_data.game_data.highest_score:
		game_data.game_data.highest_score = score
		game_data.save_game()
	
	high_score_label.text = str(game_data.game_data.highest_score)
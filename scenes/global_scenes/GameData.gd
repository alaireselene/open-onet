extends Node
## Global game data manager that handles save/load functionality and health system.
##
## Manages persistent game state including:
## - Score tracking
## - Health system with auto-revival
## - Grid state
## - Timer state
## - Game progress
##
## This singleton is autoloaded as "GameData" and persists data to user://savegame.json.

## Maximum health points player can have
const MAX_HEALTH := 5
## Hours required for one health point to regenerate
const HEALTH_REVIVAL_HOURS := 24
## File path for saving game data
const SAVE_PATH := "user://savegame.json"

## Tracks highest score achieved across games
var highest_score := 0
## Current player health points
var current_health := MAX_HEALTH
## Unix timestamp of last save
var last_saved_timestamp := 0

## Dictionary containing all persistent game state [br]
## Keys: [br]
## - grid_state: Array of tile positions and types [br]
## - current_score: Player's current score [br]
## - time_left: Remaining level time in seconds [br]
## - highest_score: Best score achieved [br]
## - chain_count: Current combo chain [br]
## - current_health: Player's health points [br]
## - last_saved_timestamp: When game was last saved
var game_data := {
	"grid_state": [],
	"current_score": 0,
	"time_left": 0,
	"highest_score": 0,
	"chain_count": 0,
	"current_health": MAX_HEALTH,
	"last_saved_timestamp": 0
}

## Saves current game state to disk [br]
## Updates all game_data fields before saving
func save_game() -> void:
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		# Update all game data before saving
		game_data = {
			"grid_state": get_node(".").grid_data if get_node(".") else [],
			"current_score": ScoreAlgorithms.score,
			"time_left": TimeManager.time_left,
			"highest_score": highest_score,
			"chain_count": ScoreAlgorithms.chain_count,
			"current_health": current_health,
			"last_saved_timestamp": Time.get_unix_time_from_system()
		}
		file.store_string(JSON.stringify(game_data))
		file.close()

## Loads game state from disk [br]
## Returns: bool - True if load successful, false otherwise
func load_game() -> bool:
	if FileAccess.file_exists(SAVE_PATH):
		var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
		var json = JSON.parse_string(file.get_as_text())
		file.close()
		
		if json:
			game_data = json
			current_health = game_data.current_health
			check_health_revival()
			return true
	return false

## Checks and applies health revival based on time passed [br]
## Health points are restored based on HEALTH_REVIVAL_HOURS [br]
## Automatically saves game state if health is restored
func check_health_revival() -> void:
	var current_time := Time.get_unix_time_from_system()
	var hours_passed :float = (current_time - game_data.last_saved_timestamp) / 3600.0
	
	if hours_passed >= HEALTH_REVIVAL_HOURS:
		var revival_cycles : float = floor(hours_passed / HEALTH_REVIVAL_HOURS)
		current_health = mini(current_health + int(revival_cycles), MAX_HEALTH)
		game_data.current_health = current_health
		save_game()

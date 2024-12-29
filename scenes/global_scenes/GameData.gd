extends Node

class_name GameDataManager  # Changed from GameData to GameDataManager

# Constants
const SAVE_FILE: String = "user://savegame.json"
const MAX_HEALTH: int = 5
const SECONDS_IN_DAY: int = 86400
const POINTS_PER_COIN: int = 100

# Game data structure with type hints
var game_data: Dictionary = {
    "current_level": 1,
    "coins": 0,
    "health": MAX_HEALTH,
    "last_health_restore": 0,
    "levels": {},  # Stores level-specific data
    "highest_score": 0  # Added highest_score with a default value
}

# Level state structure
const LEVEL_STATE_TEMPLATE: Dictionary = {
    "grid_data": [],
    "score": 0,
    "time_left": 0.0,
    "completed": false
}

# Signals
signal game_loaded(success: bool)
signal game_saved(success: bool)

func _ready() -> void:
    load_game()

## Loads game data from JSON file.
#
# Returns:
# - `true` if the game data was loaded successfully.
# - `false` otherwise.
func load_game() -> bool:
    # Initialize default state if no save file exists
    if not FileAccess.file_exists(SAVE_FILE):
        print_debug("No save file found. Initializing new game data.")
        # Start with default values
        game_data = {
            "current_level": 1,
            "coins": 0,
            "health": MAX_HEALTH,
            "last_health_restore": Time.get_unix_time_from_system(),
            "levels": {},
            "highest_score": 0  # Initialize highest_score
        }
        save_game()
        game_loaded.emit(true)
        return true

    var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
    if not file:
        push_error("Failed to open save file for reading")
        game_loaded.emit(false)
        return false

    var content = file.get_as_text()
    file.close()
    
    # Handle empty file
    if content.is_empty():
        print_debug("Save file is empty. Initializing new game data.")
        game_data = {
            "current_level": 1,
            "coins": 0,
            "health": MAX_HEALTH,
            "last_health_restore": Time.get_unix_time_from_system(),
            "levels": {},
            "highest_score": 0  # Initialize highest_score
        }
        save_game()
        game_loaded.emit(true)
        return true

    var json = JSON.new()
    var parse_result = json.parse(content)
    
    if parse_result != OK:
        push_error("JSON Parse Error: " + json.get_error_message() + " at line " + str(json.get_error_line()))
        # If parse fails, backup the corrupted file and create new save
        var backup_path = SAVE_FILE + ".backup"
        var dir = DirAccess.open("user://")
        if dir.file_exists(SAVE_FILE):
            dir.copy(SAVE_FILE, backup_path)
        game_data = {
            "current_level": 1,
            "coins": 0,
            "health": MAX_HEALTH,
            "last_health_restore": Time.get_unix_time_from_system(),
            "levels": {},
            "highest_score": 0  # Initialize highest_score
        }
        save_game()
        game_loaded.emit(false)
        return false

    var data = json.get_data()
    if typeof(data) != TYPE_DICTIONARY:
        push_error("Invalid save data format")
        game_data = {
            "current_level": 1,
            "coins": 0,
            "health": MAX_HEALTH,
            "last_health_restore": Time.get_unix_time_from_system(),
            "levels": {},
            "highest_score": 0  # Initialize highest_score
        }
        save_game()
        game_loaded.emit(false)
        return false

    # Ensure all required fields exist with default values
    var required_fields = {
        "current_level": 1,
        "coins": 0,
        "health": MAX_HEALTH,
        "last_health_restore": Time.get_unix_time_from_system(),
        "levels": {},
        "highest_score": 0  # Ensure highest_score is initialized
    }
    
    for field in required_fields:
        if not data.has(field):
            data[field] = required_fields[field]

    game_data = data
    handle_health_restoration()
    game_loaded.emit(true)
    return true

## Saves game data to JSON file.
#
# Returns:
# - `true` if the game data was saved successfully.
# - `false` otherwise.
func save_game() -> bool:
    var file: FileAccess = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
    if not file:
        push_error("Failed to open " + SAVE_FILE + " for writing.")
        game_saved.emit(false)
        return false

    var json_text: String = JSON.stringify(game_data)
    file.store_string(json_text)
    file.close()
    game_saved.emit(true)
    return true

## Handles health restoration based on the last restore time.
func handle_health_restoration() -> void:
    var current_time: int = Time.get_unix_time_from_system()
    var last_restore: int = game_data.get("last_health_restore", 0)
    var time_since: int = current_time - last_restore
    var hearts_to_restore: int = time_since / SECONDS_IN_DAY

    for i in hearts_to_restore:
        if game_data.health < MAX_HEALTH:
            game_data.health += 1
            game_data.last_health_restore += SECONDS_IN_DAY
        else:
            break

    save_game()

## Decrements health by one, ensuring it doesn't go below zero.
func decrement_health() -> void:
    if game_data.health > 0:
        game_data.health -= 1
        game_data.last_health_restore = Time.get_unix_time_from_system()
        save_game()
    else:
        print_debug("Health is already at minimum.")

## Converts points to coins based on a defined ratio.
#
# Parameters:
# - `points` (int): The number of points to convert.
func points_to_coins(points: int) -> void:
    if points < 0:
        push_error("Cannot convert negative points.")
        return

    var coins_to_add: int = int(points / POINTS_PER_COIN)
    game_data.coins += coins_to_add
    save_game()

## Sets the saved state for a specific level.
#
# Parameters:
# - `level_number` (int): The level number.
# - `state` (Dictionary): The state data to save for the level.
func set_level_state(level_number: int, state: Dictionary) -> void:
    if level_number < 1:
        push_error("Invalid level number: " + str(level_number))
        return

    game_data.levels[str(level_number)] = state
    save_game()

## Retrieves the saved state for a specific level.
#
# Parameters:
# - `level_number` (int): The level number.
#
# Returns:
# - `Dictionary` containing the level state, or an empty dictionary if not found.
func get_level_state(level_number: int) -> Dictionary:
    return game_data.levels.get(str(level_number), LEVEL_STATE_TEMPLATE.duplicate())

## Saves the current state of a level
func save_level_state(level_number: int, grid_data: Array, score: int, time_left: float, completed: bool = false) -> void:
    var level_state = {
        "grid_data": grid_data,
        "score": score,
        "time_left": time_left,
        "completed": completed
    }
    
    if not game_data.levels.has(str(level_number)):
        game_data.levels[str(level_number)] = LEVEL_STATE_TEMPLATE.duplicate()
    
    game_data.levels[str(level_number)] = level_state
    save_game()

## Checks if a level has a saved state
func has_level_state(level_number: int) -> bool:
    return game_data.levels.has(str(level_number))
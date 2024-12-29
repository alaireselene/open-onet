extends Node2D

class_name ScoreCalculator

# Constants for scoring
const BASE_SCORE_PER_TILE: int = 100
const BONUS_RESET_TIME: float = 4.0  # Time threshold in seconds to reset chain
const BONUS_MULTIPLIER_FAST: int = 4
const BONUS_MULTIPLIER_SLOW: int = 2

# Variables to track scoring
var last_match_time: float = 0.0
var score: int = 0
var chain_count: int = 0

# Signals
signal score_updated(new_score: int)
signal chain_reset()

func _ready() -> void:
    pass  # Initialization if needed in the future

# Calculates the score based on tile count and current time
#
# Parameters:
# - tile_count: Number of tiles matched in the current move
# - current_time: The current timestamp when the match occurred
#
# Returns:
# - The calculated score for the current match
func calculate_score(tile_count: int, current_time: float) -> int:
    var base_score: int = tile_count * BASE_SCORE_PER_TILE

    # Check if the time since the last match exceeds the bonus reset threshold
    if last_match_time == 0 or current_time - last_match_time > BONUS_RESET_TIME:
        print("No bonus applied. Resetting chain count.")
        chain_count = 0
        last_match_time = current_time
        emit_signal("chain_reset")
        return base_score
    else:
        chain_count += 1
        var bonus_multiplier: int = determine_bonus_multiplier(current_time - last_match_time)
        last_match_time = current_time
        var total_score: int = base_score * bonus_multiplier
        print("Bonus applied. Chain count: %d, Multiplier: %d" % [chain_count, bonus_multiplier])
        return total_score

# Determines the bonus multiplier based on the time between matches
#
# Parameters:
# - time_diff: The time difference between the current match and the last match
#
# Returns:
# - The appropriate bonus multiplier
func determine_bonus_multiplier(time_diff: float) -> int:
    if time_diff < 1.0:
        return BONUS_MULTIPLIER_FAST + 2 * chain_count
    else:
        return BONUS_MULTIPLIER_SLOW + chain_count

# Adds the calculated score to the total score
#
# Parameters:
# - tile_count: Number of tiles matched in the current move
# - current_time: The current timestamp when the match occurred
#
# Returns:
# - The score gained from the current match
func add_score(tile_count: int, current_time: float) -> int:
    var gained_score: int = calculate_score(tile_count, current_time)
    score += gained_score
    emit_signal("score_updated", score)
    return gained_score

# Resets the score and chain count to their initial values
func reset_score() -> void:
    last_match_time = 0.0
    score = 0
    chain_count = 0
    emit_signal("score_updated", score)
    emit_signal("chain_reset")
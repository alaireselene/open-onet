extends Node

class_name HealthManager

# Constants
const MAX_HEALTH :int= 5
const RESTORE_INTERVAL:int = 86400 ## 24 hours in seconds

# Signals
signal health_updated(current_health: int)

# Internal variables
@onready var game_data = %GameData
var current_health :int= MAX_HEALTH
var last_played_time: float = 0.0

func _ready() -> void:
    load_health_state()
    schedule_health_restoration()

func load_health_state() -> void:
    var saved_health = game_data.game_data.current_health
    var saved_last_played = game_data.game_data.last_played_time
    current_health = clamp(saved_health, 0, MAX_HEALTH)
    last_played_time = saved_last_played

    health_updated.emit(current_health)

func decrement_health() -> void:
    if current_health > 0:
        current_health -= 1
        last_played_time = Time.get_unix_time_from_system()
        health_updated.emit(current_health)
        save_health_state()

func restore_health() -> void:
    if current_health < MAX_HEALTH:
        current_health += 1
        health_updated.emit(current_health)
        save_health_state()

func schedule_health_restoration() -> void:
    var current_time = Time.get_unix_time_from_system()
    var time_since_last_play = current_time - last_played_time
    if time_since_last_play >= RESTORE_INTERVAL and current_health < MAX_HEALTH:
        restore_health()
    elif current_health < MAX_HEALTH:
        var time_until_restore = RESTORE_INTERVAL - time_since_last_play
        await get_tree().create_timer(time_until_restore).timeout
        restore_health()

func save_health_state() -> void:
    game_data.game_data.current_health = current_health
    game_data.game_data.last_played_time = last_played_time
    game_data.save_game()
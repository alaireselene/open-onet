extends Node

class_name GameUtils

static func reset_game_state ():
	AudioPlayer.restart_music()
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	Engine.time_scale = 1
	TimeManager.start_timer()
	
	
static func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var remaining_seconds = int(seconds) % 60
	return "%02d:%02d" % [minutes, remaining_seconds]
	
	
	

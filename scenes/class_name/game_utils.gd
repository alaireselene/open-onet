extends Node

class_name GameUtils

static func reset_game_state ():
	Engine.time_scale = 1
	TimeManager.reset_time()
	ScoreAlgorithms.reset_score()
	AudioPlayer.restart_music()

extends Node2D
#var match_timer : Timer
#var elapsed_time : int = 0
var limited_time_bonus = 4	
var last_match_time = 0
var score = 0
var chain_count = 0

func _ready():
	#match_timer = Timer.new()
	#add_child(match_timer)
	#match_timer.start(1.0)
	#match_timer.connect("timeout", Callable(self, "_on_match_timeout"))
	pass
	

func _on_timer_timeout():
	#elapsed_time += 1
	#print(elapsed_time)
	#
	pass

func calculate_score(tile_count: int, current_time: float) -> int:
	var base_score = tile_count * 100

	# Kiểm tra nếu thời gian giữa các lần match quá 2 giây, reset chuỗi
	if last_match_time == 0 or current_time - last_match_time > limited_time_bonus:
		print("No bonus")
		chain_count = 0
		last_match_time = current_time
		return base_score
	else:
		print("bonus")
		chain_count += 1
		var bonus_multiplier : int
		if current_time - last_match_time <1:
			bonus_multiplier = 4 + 2 * chain_count
		else:
			bonus_multiplier = 2+chain_count
		last_match_time = current_time
		return base_score * bonus_multiplier 



func add_score(tile_count: int, current_time: float) -> int:
	var gained_score = calculate_score(tile_count, current_time)
	score += gained_score
	return gained_score

func reset_score():
	last_match_time = 0
	score = 0
	chain_count = 0

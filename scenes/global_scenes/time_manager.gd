extends Node

# Quản lý thời gian và trạng thái
var total_time = 20
var time_left = 20  # Thời gian mặc định (giây)
var paused = false
var timer_active = false
var finished_time1 = 0

# Signal để thông báo khi hết giờ
signal timeout

# Reset trạng thái và thời gian
func reset_time():
	time_left = total_time
	paused = false
	timer_active = false

# Bắt đầu đếm ngược thời gian
func start_timer():
	timer_active = true

# Dừng đếm ngược thời gian
func stop_timer():
	timer_active = false

# Giảm thời gian, phát tín hiệu nếu hết giờ
func update_time(delta: float):
	if timer_active and not paused and time_left > 0:
		time_left -= delta
		if time_left <= 0:
			time_left = 0
			timer_active = false
			emit_signal("timeout")
	return time_left

func finished_time(delta: float):
	finished_time1 = total_time - update_time(delta) 
	return finished_time1
# Tạm dừng hoặc tiếp tục


func toggle_pause():
	paused = !paused
	return paused

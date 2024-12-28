extends AudioStreamPlayer

const level_music = preload("res://assets/audio/title-screen.mp3")
const main_menu_music = preload("res://assets/audio/title-screen.mp3")

var paused_position = 0.0  # Biến lưu vị trí bị tạm dừng

func _play_music(music: AudioStream, volume = 0.0):
	if stream == music:
		return
	stop()
	stream = music
	volume_db = volume
	paused_position = 0.0  # Đặt lại vị trí khi phát nhạc mới
	play()

func play_music_level():
	_play_music(level_music)

func play_music_main_menu():
	_play_music(main_menu_music)

func pause_music():
	if is_playing():
		paused_position = get_playback_position()  # Lưu vị trí hiện tại
		stop()  # Tạm dừng nhạc bằng cách dừng phát

func resume_music():
	if paused_position > 0.0:
		play(paused_position)  # Phát lại từ vị trí bị tạm dừng
		paused_position = 0.0  # Xóa vị trí sau khi phát lại

func restart_music():
	stop()
	play()  # Phát lại từ đầu

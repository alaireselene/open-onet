extends LevelSelector

func _ready():
	# Kết nối tự động các nút trong container "Level list/Level button"
	var buttons_container = $"Level list/Level button"
	connect_level_buttons(buttons_container)

func _on_close_pressed():
	SceneHistory.go_back()

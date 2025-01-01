class_name LevelSelector
extends Control

# Hàm xử lý chọn cấp độ
func select_level(level: int) -> void:
	GameSettings.set_level(level)  # Thiết lập cấp độ
	SceneLoader.load_scene("res://scenes/game_mode/arcade/level/level.tscn")  # Tải scene

# Hàm kết nối các nút tự động
func connect_level_buttons(buttons_container: Node) -> void:
	# Lặp qua các nút trong container
	for button in buttons_container.get_children():
		if button is Button:  # Kiểm tra nếu là Button
			# Trích xuất cấp độ từ tên nút (Level_1, Level_2, ...)
			var level = int(button.name.replace("Level_", ""))
			# Kết nối sự kiện pressed với hàm xử lý
			button.pressed.connect(Callable(self, "_on_level_pressed").bind(level))

# Hàm xử lý khi một nút được bấm
func _on_level_pressed(level: int) -> void:
	select_level(level)

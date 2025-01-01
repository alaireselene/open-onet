extends Node

var highest_score: int = 0

const SAVE_FILE_PATH = "user://save_game_data.json"

func _ready():
	# Tải dữ liệu khi khởi động
	load_data()

func save_data():
	# Lưu dữ liệu vào file
	var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file:
		var data = {"highest_score": highest_score}
		var json = JSON.new()
		var json_string = json.stringify(data)
		file.store_string(json_string)
		file.close()
		print("Game data saved.")
	else:
		print("Failed to save game data.")

func load_data():
	# Tải dữ liệu từ file
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if file:
			var json = JSON.new()
			var json_text = file.get_as_text()
			var result = json.parse(json_text)
			if result == OK:
				var data = json.get_data()
				highest_score = data.get("highest_score", 0)
				print("Game data loaded:", data)
			else:
				print("Failed to parse JSON.")
			file.close()
		else:
			print("Failed to read save file.")
	else:
		print("No save file found. Using default data.")
		
		

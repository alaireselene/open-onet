extends Resource
class_name LevelData

@export var grid_width: int
@export var grid_height: int
@export var shape_data: Array
@export var collapse_behavior: String
@export var time_limit: float

func load_level(level_number: int) -> bool:
	var file_path = "res://data/levels/" + str(level_number) + ".json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	if file:
		var json_content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_content)
		
		if error == OK:
			var data = json.get_data()
			grid_width = data.get("width", 8)
			grid_height = data.get("height", 8)
			shape_data = data.get("shape", [])
			collapse_behavior = data.get("collapse", "down")
			time_limit = data.get("time_limit", 300.0)
			return true
		else:
			push_error("JSON Parsing Error in " + file_path)
			return false
	else:
		push_error("Failed to open " + file_path)
		return false

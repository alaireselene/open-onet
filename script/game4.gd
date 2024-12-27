extends Node

var grid_size := Vector2(80*20, 80*20)
var cell_size := Vector2(80, 80)
var cell_amount := Vector2(grid_size.x/cell_size.x, grid_size.y/cell_size.y)

# Pokemon Data
var pokemon_data = {}

func _ready():
	load_pokemon_data()

func load_pokemon_data():
	var dir = DirAccess.open("res://assets scene") # Assuming your Pokemon scenes are in a folder called "pokemons"
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var id = 0
		while file_name != "":
			if !dir.current_is_dir():
				var pokemon_scene = load("res://assets scene/" + file_name)
				if pokemon_scene:
					pokemon_data[id] = {
						"id": id,
						"name": file_name.get_basename(),  # Extract name without extension
						"scene": pokemon_scene
					}
				id += 1
			file_name = dir.get_next()
		dir.list_dir_end()
	else:
		print("Error: Could not open directory 'res://assets scene'")

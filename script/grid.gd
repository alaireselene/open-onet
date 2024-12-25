extends Node2D

class_name Grid

var grid_data = []
var selected_tile = null

func _ready() -> void:
	generate_grid()

func _draw() -> void:
	draw_rect(Rect2(0, 0, Game.grid_size.x, Game.grid_size.y), Colors.YELLOW)
	for i in range(Game.cell_amount.x):
		var from := Vector2(i*Game.cell_size.x, 0)
		var to := Vector2(from.x, Game.grid_size.y)
		draw_line(from, to, Colors.GREYFORLINING, 2.0)
	for i in range(Game.cell_amount.y):
		var from := Vector2(0, i*Game.cell_size.y)
		var to := Vector2(Game.grid_size.x, from.y)
		draw_line(from, to, Colors.GREYFORLINING, 2.0)

func generate_grid():
	# 1. Determine Pokemon types for each cell (using a grid generation algorithm)
	grid_data = generate_grid_data(Game.cell_amount.x, Game.cell_amount.y, Game.pokemon_data)

	# 2. Spawn Pokemon based on grid_data
	for y in range(grid_data.size()):
		for x in range(grid_data[y].size()):
			var pokemon_id = grid_data[y][x]
			if pokemon_id != -1:  # -1 represents an empty cell (if any)
				var Position = Vector2(x * Game.cell_size.x + Game.cell_size.x / 2, y * Game.cell_size.y + Game.cell_size.y / 2)
				spawn_pokemon(Position, pokemon_id)

func spawn_pokemon(Position, pokemon_id):
	var pokemon_scene = Game.pokemon_data[pokemon_id].scene
	if pokemon_scene:
		var pokemon_instance = pokemon_scene.instantiate()
		add_child(pokemon_instance)
		
		# Set the position to the center of the cell
		pokemon_instance.position = Position
		
		# You can optionally set the Pokemon's name based on the data
		pokemon_instance.name = "Pokemon_" + Game.pokemon_data[pokemon_id].name
		pokemon_instance.connect("input_event", _on_Pokemon_input_event.bind(pokemon_instance))

func _on_Pokemon_input_event(viewport, event, shape_idx, clicked_pokemon):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Pokemon clicked!")

			if is_instance_valid(clicked_pokemon):
				print("Clicked Pokemon:", clicked_pokemon.name)
				if selected_tile == null:
					# Select the first tile
					selected_tile = clicked_pokemon
					print("Selected tile: ", selected_tile.name)
					# Highlight the selected tile (optional)
					selected_tile.material.set_shader_parameter("outline_color", Colors.REDTRACELINE) # Example: Add an outline
				elif selected_tile != clicked_pokemon:
					# Select the second tile
					var second_tile = clicked_pokemon
					print("Second tile: ", second_tile.name)
					# We are not checking for match now
					print("Fake Match found!")
					# Remove the matched tiles (we will implement this logic later)
					selected_tile.queue_free()
					second_tile.queue_free()

					# Unselect tiles
					selected_tile = null
				else:
					# Clicked the same tile twice, unselect it
					selected_tile = null
					print("Tile unselected")
			else:
				print("Could not find clicked Pokemon using shape owner ID.")

func generate_grid_data(width, height, pokemon_data):
	var grid = []
	var num_pokemon_types = pokemon_data.size()
	var total_cells = width * height

	# 1. Calculate how many pairs of each Pokémon we can fit
	var pairs_per_type = total_cells / (num_pokemon_types * 2)
	var remaining_cells = total_cells - pairs_per_type*2*num_pokemon_types

	# 2. Create a list of Pokémon IDs with pairs
	var pokemon_ids = []
	for i in range(num_pokemon_types):
		for j in range(pairs_per_type):
			pokemon_ids.append(i)
			pokemon_ids.append(i)  # Add each ID twice for a pair
	# Fill the rest of the remaining cells with random Pokemon, ensuring pairs
	while pokemon_ids.size() < total_cells:
		var random_type = abs(randi() % num_pokemon_types) # Use abs() here
		pokemon_ids.append(random_type)
		pokemon_ids.append(random_type)

	# 4. Shuffle the list to randomize placement
	pokemon_ids.shuffle()

	# 5. Fill the grid
	var index = 0
	for y in range(height):
		var row = []
		for x in range(width):
			row.append(pokemon_ids[index])
			index += 1
		grid.append(row)
	# 6. Check solvability and regenerate if necessary
	return grid

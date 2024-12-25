
	# 4. Check solvability and regenerate if necessary
	while not is_grid_solvable(grid):
		# Shuffle again or apply a more sophisticated algorithm
		pokemon_ids.shuffle()
		grid = []
		index = 0
		for y in range(height):
			var row = []
			for x in range(width):
				row.append(pokemon_ids[index])
				index += 1
			grid.append(row)
			
			
			
			
			

func is_grid_solvable(grid):
	# Implement the inversion counting algorithm here
	# ... (See explanation above)
	pass
	
	
	
	func generate_grid_data(width, height, pokemon_data):
	var grid = []
	var num_pokemon_types = pokemon_data.size()
	var total_cells = width * height

	# 1. Calculate how many pairs of each Pokémon we can fit
	var pairs_per_type = total_cells / (num_pokemon_types * 2)
	var remaining_cells = total_cells % (num_pokemon_types * 2)

	# 2. Create a list of Pokémon IDs with pairs
	var pokemon_ids = []
	for i in range(num_pokemon_types):
		for j in range(pairs_per_type):
			pokemon_ids.append(i)
			pokemon_ids.append(i)  # Add each ID twice for a pair

	# 3. Fill remaining cells with random pairs
	# Ensure remaining_cells is even
	if remaining_cells % 2 != 0:
		remaining_cells += 1

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
	while not is_grid_solvable(grid):
		# Shuffle again or apply a more sophisticated algorithm
		pokemon_ids.shuffle()
		grid = []
		index = 0
		for y in range(height):
			var row = []
			for x in range(width):
				row.append(pokemon_ids[index])
				index += 1
			grid.append(row)

	return grid

if is_valid_match(selected_tile.id, second_tile.id):
						print("Match found!")
						# Remove the matched tiles (we will implement this logic later)
						selected_tile.queue_free()
						second_tile.queue_free()
					else:
						print("Invalid match!")
					# Unselect tiles
					selected_tile = null

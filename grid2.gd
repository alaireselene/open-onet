extends Node2D

class_name Grid2

var grid_data = []
var selected_tile = null
var selected_tile_pos = null
var pokemon_map = {}  # Dictionary to map grid positions to Pokemon instances
func _ready() -> void:
	generate_grid()



func _draw() -> void:
	## Draw the grid lines for the inner area onlym
	#for i in range(1, int(Game2.cell_amount.x - 1)):
		#var from := Vector2(i * Game2.cell_size.x, Game2.cell_size.y)
		#var to := Vector2(from.x, Game2.grid_size.y - Game2.cell_size.y)
		#draw_line(from, to, Colors.GREYFORLINING, 2.0)
	#for i in range(1, int(Game2.cell_amount.y - 1)):
		#var from := Vector2(Game2.cell_size.x, i * Game2.cell_size.y)
		#var to := Vector2(Game2.grid_size.x - Game2.cell_size.x, from.y)
		#draw_line(from, to, Colors.GREYFORLINING, 2.0)

	# Draw the outline for the selected tile
	if selected_tile_pos != null:
		var outline_rect = Rect2(selected_tile_pos.x, selected_tile_pos.y, Game2.cell_size.x, Game2.cell_size.y)
		draw_line(outline_rect.position, outline_rect.position + Vector2(outline_rect.size.x, 0), Color.RED, 5.0)
		draw_line(outline_rect.position + Vector2(outline_rect.size.x, 0), outline_rect.position + outline_rect.size, Color.RED, 5.0)
		draw_line(outline_rect.position + outline_rect.size, outline_rect.position + Vector2(0, outline_rect.size.y), Color.RED, 5.0)
		draw_line(outline_rect.position + Vector2(0, outline_rect.size.y), outline_rect.position, Color.RED, 5.0)



func remove_matched_tiles(tile1, tile2):
	# Remove the Pokemon instances from the scene and the dictionary
	var grid_pos1 = get_grid_pos(tile1.position)
	var grid_pos2 = get_grid_pos(tile2.position)

	if pokemon_map.has(grid_pos1):
		pokemon_map.erase(grid_pos1)
	if pokemon_map.has(grid_pos2):
		pokemon_map.erase(grid_pos2)
	
	tile1.queue_free()
	tile2.queue_free()

	# Update grid_data to mark the cells as empty
	grid_data[int(grid_pos1.y)][int(grid_pos1.x)] = -1  # Assuming -1 represents an empty cell
	grid_data[int(grid_pos2.y)][int(grid_pos2.x)] = -1

	# Redraw the grid to reflect the changes
	queue_redraw()




func generate_grid():
	# 1. Create a grid with a 1-cell border of empty cells (-1)
	grid_data = []
	for y in range(int(Game2.cell_amount.y)):
		var row = []
		for x in range(int(Game2.cell_amount.x)):
			if x == 0 or x == Game2.cell_amount.x - 1 or y == 0 or y == Game2.cell_amount.y - 1:
				row.append(-1)  # Empty cell for the border
			else:
				row.append(0)   # Placeholder for Pokemon, will be filled later
		grid_data.append(row)

	# 2. Determine Pokemon types for the inner cells (excluding the border)
	var inner_width = int(Game2.cell_amount.x - 2)
	var inner_height = int(Game2.cell_amount.y - 2)
	var inner_grid_data = generate_grid_data(inner_width, inner_height, Game2.pokemon_data)

	# 3. Copy the inner grid data to the main grid, offset by 1 cell
	for y in range(inner_height):
		for x in range(inner_width):
			grid_data[y + 1][x + 1] = inner_grid_data[y][x]

	# 4. Spawn Pokemon based on grid_data (only for non-border cells)
	for y in range(grid_data.size()):
		for x in range(grid_data[y].size()):
			var pokemon_id = grid_data[y][x]
			if pokemon_id != -1:  # -1 represents an empty cell
				var position = Vector2(x * Game2.cell_size.x + Game2.cell_size.x / 2, y * Game2.cell_size.y + Game2.cell_size.y / 2)
				spawn_pokemon(position, pokemon_id)
				
	# Check if the initial grid has valid matches, shuffle if not
	while not check_game_state():
		print("Initial grid has no matches, shuffling...")
		shuffle_grid()

func check_game_state():
	# Check if there are any valid moves left
	for y1 in range(1, int(Game2.cell_amount.y - 1)):
		for x1 in range(1, int(Game2.cell_amount.x - 1)):
			if grid_data[y1][x1] != -1:  # If cell is not empty
				for y2 in range(1, int(Game2.cell_amount.y - 1)):
					for x2 in range(1, int(Game2.cell_amount.x - 1)):
						if y1 == y2 and x1 == x2:
							continue
						if grid_data[y2][x2] != -1:  # If cell is not empty
							var pos1 = Vector2(x1, y1)
							var pos2 = Vector2(x2, y2)
							var tile1 = get_pokemon_at_pos(pos1) # Use get_pokemon_at_pos instead
							var tile2 = get_pokemon_at_pos(pos2) # Use get_pokemon_at_pos instead
							if tile1 != tile2 and tile1 != null and tile2 != null and is_valid_match(tile1, tile2):
								return true  # Game2 has valid move
	return false  # No valid moves found

func shuffle_grid():
	# 1. Collect the IDs of the remaining Pokemon and their positions
	var remaining_pokemon_ids = []
	var pokemon_positions = []
	for y in range(1, int(Game2.cell_amount.y - 1)):
		for x in range(1, int(Game2.cell_amount.x - 1)):
			if grid_data[y][x] != -1:
				var pos = Vector2(x, y)
				var pokemon = get_pokemon_at_pos(pos)
				if pokemon:
					remaining_pokemon_ids.append(pokemon.get_meta("id"))
					pokemon_positions.append(pos)

	# 2. Remove existing Pokemon instances from the scene
	for child in get_children():
		if child is Node2D and "Pokemon_" in child.name:
			child.queue_free()

	# Clear the pokemon_map
	pokemon_map.clear()

	# 3. Shuffle the list of remaining Pokemon IDs
	remaining_pokemon_ids.shuffle()

	# 4. Update grid_data and spawn new Pokemon at the original positions
	for i in range(len(remaining_pokemon_ids)):
		var pos = pokemon_positions[i]
		var pokemon_id = remaining_pokemon_ids[i]
		grid_data[int(pos.y)][int(pos.x)] = pokemon_id
		var position = Vector2(pos.x * Game2.cell_size.x + Game2.cell_size.x / 2, pos.y * Game2.cell_size.y + Game2.cell_size.y / 2)
		spawn_pokemon(position, pokemon_id)

	# 5. Redraw the grid
	queue_redraw()

func spawn_pokemon(position, pokemon_id):
	var pokemon_scene = Game2.pokemon_data[pokemon_id].scene
	if is_instance_valid(pokemon_scene):
		var pokemon_instance = pokemon_scene.instantiate()
		if is_instance_valid(pokemon_instance):
			add_child(pokemon_instance)
			
			# Set the position to the center of the cell
			pokemon_instance.position = position
			
			# Set the Pokemon's name based on the data and assign id to it
			pokemon_instance.name = "Pokemon_" + Game2.pokemon_data[pokemon_id].name
			pokemon_instance.set_meta("id", pokemon_id)
			
			# Connect the Pokemon's input_event signal to the Grid's _on_Pokemon_input_event function
			pokemon_instance.connect("input_event", _on_Pokemon_input_event.bind(pokemon_instance))

			# Add the Pokemon instance to the pokemon_map
			var grid_pos = get_grid_pos(position)
			pokemon_map[grid_pos] = pokemon_instance
		else:
			print("Error: Could not instantiate Pokemon scene.")
	else:
		print("Error: Pokemon scene not found for ID: ", pokemon_id)

func get_pokemon_at_pos(grid_pos):
	if pokemon_map.has(grid_pos):
		return pokemon_map[grid_pos]
	else:
		return null

func _on_Pokemon_input_event(viewport, event, shape_idx, clicked_pokemon):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Pokemon clicked!")

			if is_instance_valid(clicked_pokemon):
				print("Clicked Pokemon:", clicked_pokemon.name)
				# Convert the clicked Pokemon's position to grid coordinates
				var grid_pos = clicked_pokemon.position - Game2.cell_size / 2
				grid_pos = Vector2(int(grid_pos.x / Game2.cell_size.x), int(grid_pos.y / Game2.cell_size.y))

				if selected_tile == null:
					# Select the first tile
					selected_tile = clicked_pokemon
					selected_tile_pos = grid_pos * Game2.cell_size # Store the position for _draw()
					print("Selected tile: ", selected_tile.name)
					# Redraw the grid to show the outline
					queue_redraw()
				elif selected_tile != clicked_pokemon:
					# Select the second tile
					var second_tile = clicked_pokemon
					print("Second tile: ", second_tile.name)
					# Check for match (only ID for now)
					if is_valid_match(selected_tile, second_tile):
						print("Match found!")
						# Remove the matched tiles 
						remove_matched_tiles(selected_tile, second_tile)
					else:
						print("Invalid match!")
					# Unselect tiles
					selected_tile = null
					selected_tile_pos = null
					# Redraw the grid to remove the outline
					queue_redraw()
				else:
					# Clicked the same tile twice, unselect it
					selected_tile_pos = null
					selected_tile = null
					print("Tile unselected")
					# Redraw the grid to remove the outline
					queue_redraw()
			else:
				print("Could not find clicked Pokemon using shape owner ID.")

func is_valid_match(tile1, tile2):
	# Check if same type using metadata
	if tile1.has_meta("id") and tile2.has_meta("id"):
		if tile1.get_meta("id") == tile2.get_meta("id"):
			# Check for valid path
			if is_valid_path(tile1, tile2):
				return true
			else:
				return false
		else:
			return false
	else:
		return false


func is_valid_path(tile1, tile2):
	# Get grid positions of the tiles
	var tile1_grid_pos = get_grid_pos(tile1.position)
	var tile2_grid_pos = get_grid_pos(tile2.position)
	# Check for direct path (1 segment)
	if check_direct_path(tile1_grid_pos, tile2_grid_pos):
		print("1-segment path found")
		return true
	# Check for 2-segment paths
	if check_two_segment_path(tile1_grid_pos, tile2_grid_pos):
		print("2-segment path found")
		return true
	# Check for 3-segment paths (simplified for internal paths)
	if check_three_segment_path(tile1_grid_pos, tile2_grid_pos):
		print("3-segment path found")
		return true

	return false

func check_direct_path(pos1, pos2):
	# Check if tiles are in the same row or column
	if pos1.x != pos2.x and pos1.y != pos2.y:
		return false
	# Check for empty cells between the tiles
	if pos1.x == pos2.x:  # Same column
		var start_y = min(pos1.y, pos2.y)
		var end_y = max(pos1.y, pos2.y)
		for y in range(start_y + 1, end_y):
			if not is_cell_empty(Vector2(pos1.x, y)):
				print("Direct path blocked at: ", Vector2(pos1.x, y))
				return false
	else:  # Same row
		var start_x = min(pos1.x, pos2.x)
		var end_x = max(pos1.x, pos2.x)
		for x in range(start_x + 1, end_x):
			if not is_cell_empty(Vector2(x, pos1.y)):
				print("Direct path blocked at: ", Vector2(x, pos1.y))
				return false
	return true


func get_grid_pos(position):
	var grid_pos = position - Game2.cell_size / 2
	return Vector2(int(grid_pos.x / Game2.cell_size.x), int(grid_pos.y / Game2.cell_size.y))

func is_cell_empty(grid_pos):
	# Check if the cell is within the grid bounds
	if not is_valid_position(grid_pos):
		return false  # Treat out-of-bounds cells as non-empty to prevent pathfinding outside the grid
	return grid_data[int(grid_pos.y)][int(grid_pos.x)] == -1


func is_valid_position(pos):
	# Check if the position is within the grid bounds, including the border
	return pos.x >= 0 and pos.x < Game2.cell_amount.x and pos.y >= 0 and pos.y < Game2.cell_amount.y

func check_two_segment_path(pos1, pos2):
	# Check for L-shaped paths
	var corner1 = Vector2(pos1.x, pos2.y)
	var corner2 = Vector2(pos2.x, pos1.y)
	if is_cell_empty(corner1) and check_direct_path(pos1, corner1) and check_direct_path(corner1, pos2):
		return true

func check_three_segment_path(pos1, pos2):
	# Check for paths with both intermediate corners inside the grid
	for x in range(int(Game2.cell_amount.x)):
		for y in range(int(Game2.cell_amount.y)):
			var corner1 = Vector2(x, pos1.y)
			var corner2 = Vector2(x, pos2.y)
			if is_valid_internal_path(pos1, corner1, corner2, pos2):
				return true

			corner1 = Vector2(pos1.x, y)
			corner2 = Vector2(pos2.x, y)
			if is_valid_internal_path(pos1, corner1, corner2, pos2):
				return true

	return false

func is_valid_internal_path(pos1, corner1, corner2, pos2):
	if not is_valid_position(corner1) or not is_valid_position(corner2):
		return false
	if not is_cell_empty(corner1) or not is_cell_empty(corner2):
		return false
	return check_direct_path(pos1, corner1) and check_direct_path(corner1, corner2) and check_direct_path(corner2, pos2)

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

	# 3. Fill remaining cells with random pairs, ensuring even distribution
	# Ensure remaining_cells is even by adding a random pair if it's odd
	if remaining_cells % 2 != 0:
		remaining_cells += 1
		var random_type = randi() % num_pokemon_types
		pokemon_ids.append(random_type)
		pokemon_ids.append(random_type)

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

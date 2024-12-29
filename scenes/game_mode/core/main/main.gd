extends Node2D

signal score_updated(score: int)
signal _on_all_matched
signal tile_selected(tile: Button)  # Update signal type

@onready var level_data = preload("res://scenes/game_mode/core/main/LevelData.gd").new()
@onready var game_data: GameDataManager = $"/root/GameData"

var grid_data: Array = []
var selected_tile: Button = null  # Update variable type
var can_play: bool = true
var current_score: int = 0
var current_time_left: float = 0.0

func _ready():
	var current_level = game_data.game_data.current_level
	
	# Check for existing saved state
	if game_data.has_level_state(current_level):
		var saved_state = game_data.get_level_state(current_level)
		restore_game_state(saved_state)
	else:
		if level_data.load_level(current_level):
			initialize_grid()
			current_time_left = level_data.time_limit
		else:
			push_error("Failed to load level data")

func restore_game_state(state: Dictionary) -> void:
	grid_data = state.grid_data
	current_score = state.score
	current_time_left = state.time_left
	rebuild_grid_from_data()
	emit_signal("score_updated", current_score)

func initialize_grid():
	grid_data.clear()

	# Create grid based on level shape
	for y in range(level_data.grid_height):
		var row = []
		for x in range(level_data.grid_width):
			if level_data.shape_data.is_empty() or level_data.shape_data[y][x] == 1:
				var tile = create_tile(x, y)
				row.append(tile)
			else :
				row.append(null)
		grid_data.append(row)  # Append the row to grid_data to prevent out-of-bounds access
	shuffle_grid()

func create_tile(x: int, y: int) -> Button:  # Change return type to Button
	var tile_scene = preload("res://scenes/game_mode/core/tile/Tile.tscn")
	var tile = tile_scene.instantiate() as Button  # Explicitly cast to Button
	tile.position = Vector2(x * 64, y * 64)
	tile.grid_position = Vector2i(x, y)  # Changed to Vector2i
	tile.tile_pressed.connect(_on_tile_pressed.bind(tile))  # Changed from pressed to tile_pressed
	add_child(tile)
	return tile

func shuffle_grid():
	var tiles = []
	var positions = []

	# Collect all tiles and their positions
	for y in range(level_data.grid_height):
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				tiles.append(grid_data[y][x])
				positions.append(Vector2i(x, y))  # Changed to Vector2i

	# Shuffle tiles and reposition them
	tiles.shuffle()
	for i in range(tiles.size()):
		var tile = tiles[i]
		var pos = positions[i]
		grid_data[pos.y][pos.x] = tile
		tile.position = Vector2(pos.x * 64, pos.y * 64)
		tile.grid_position = pos

func _on_tile_pressed(tile: Button):  # Update parameter type
	if !can_play:
		return

	if selected_tile == null:
		selected_tile = tile
		tile.select()
		emit_signal("tile_selected", tile)
	else:
		if selected_tile == tile:
			selected_tile.deselect()
			selected_tile = null
		else:
			if can_connect(selected_tile, tile):
				handle_match(selected_tile, tile)
			selected_tile.deselect()
			selected_tile = null

func can_connect(tile1: Button, tile2: Button) -> bool:  # Update parameter types
	if tile1.type != tile2.type:
		return false
	
	var path = find_path(tile1.grid_position, tile2.grid_position)
	return path != null

func find_path(start: Vector2i, end: Vector2i) -> Array:
	# Try direct path
	if can_move_direct(start, end):
		return [start, end]

	# Try 1 corners (L-shape) paths
	var corner = find_one_corner_path(start, end)
	if corner and corner != Vector2i(-1, -1):
		return [start, corner, end]

	# Try 2 corners (Z-shape or C-shape) paths
	var corners = find_two_corners_path(start, end)
	if corners:
		return [start, corners[0], corners[1], end]

	return []

func can_move_direct(start: Vector2i, end: Vector2i) -> bool:
	# Check if points are on the same row or column
	if start.x != end.x and start.y != end.y:
		return false
	
	# Check if there are any obstacles between points
	if start.x == end.x:
		var min_y = min(start.y, end.y)
		var max_y = max(start.y, end.y)
		for y in range(min_y + 1, max_y):
			if grid_data[y][start.x]:
				return false
	else:
		var min_x = min(start.x, end.x)
		var max_x = max(start.x, end.x)
		for x in range(min_x + 1, max_x):
			if grid_data[start.y][x]:
				return false

	return true

func find_one_corner_path(start: Vector2i, end: Vector2i) -> Vector2i:
	# Try corner at (start.x, end.y)
	var corner1 = Vector2i(start.x, end.y)
	if corner1 != start and corner1 != end:
		if can_move_direct(start, corner1) and can_move_direct(corner1, end):
			if !grid_data[corner1.y][corner1.x]:
				return corner1

	# Try corner at (end.x, start.y)
	var corner2 = Vector2i(end.x, start.y)
	if corner2 != start and corner2 != end:
		if can_move_direct(start, corner2) and can_move_direct(corner2, end):
			if !grid_data[corner2.y][corner2.x]:
				return corner2

	return Vector2i(-1, -1)

func find_two_corners_path(start: Vector2i, end: Vector2i) -> Array:
	# Try all possible first corners
	for x in range(level_data.grid_width):
		for y in range(level_data.grid_height):
			var corner1 = Vector2i(x, y)
			if corner1 == start or corner1 == end:
				continue
			if grid_data[y][x]:
				continue
			
			# If we can reach corner1 from start
			if can_move_direct(start, corner1):
				# Try all possible second corners
				var corner2_attempts = [
					Vector2i(corner1.x, end.y),
					Vector2i(end.x, corner1.y)
				]

				for corner2 in corner2_attempts:
					if corner2 != corner1 and corner2 != end:
						if !grid_data[corner2.y][corner2.x]:
							if can_move_direct(corner1, corner2) and can_move_direct(corner2, end):
								return [corner1, corner2]

	return []

func handle_match(tile1: Button, tile2: Button):  # Update parameter types
	# Handle tile match
	remove_tiles(tile1, tile2)

	match level_data.collapse_behavior:
		"down":
			collapse_down()
		"left":
			collapse_left()
		"right":
			collapse_right()
		"up":
			collapse_up()

	ScoreAlgorithms.add_match()
	emit_signal("score_updated", ScoreAlgorithms.score)

	if is_grid_empty():
		emit_signal("all_matched")
	
	# Save state after each match
	save_current_state()

func save_current_state() -> void:
	var current_level = game_data.game_data.current_level
	game_data.save_level_state(
		current_level,
		grid_data,
		current_score,
		current_time_left,
		is_grid_empty()
	)

func remove_tiles(tile1: Button, tile2: Button):  # Update parameter types to Button
	grid_data[tile1.grid_position.y][tile1.grid_position.x] = null
	grid_data[tile2.grid_position.y][tile2.grid_position.x] = null
	tile1.queue_free()
	tile2.queue_free()

func collapse_up():
	for x in range(level_data.grid_width):
		var write_y = 0
		for y in range(level_data.grid_height):
			if grid_data[y][x]:
				if y != write_y:
					grid_data[write_y][x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[write_y][x]
					tile.position.y = write_y * 64
					tile.grid_position.y = write_y
				write_y += 1

func collapse_down():
	for x in range(level_data.grid_width):
		var write_y = level_data.grid_height - 1
		for y in range(level_data.grid_height - 1, -1, -1):
			if grid_data[y][x]:
				if y != write_y:
					grid_data[write_y][x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[write_y][x]
					tile.position.y = write_y * 64
					tile.grid_position.y = write_y
				write_y -= 1

func collapse_left():
	for y in range(level_data.grid_height):
		var write_x = 0
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				if x != write_x:
					grid_data[y][write_x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[y][write_x]
					tile.position.x = write_x * 64
					tile.grid_position.x = write_x
				write_x += 1

func collapse_right():
	for y in range(level_data.grid_height):
		var write_x = level_data.grid_width - 1
		for x in range(level_data.grid_width - 1, -1, -1):
			if grid_data[y][x]:
				if x != write_x:
					grid_data[y][write_x] = grid_data[y][x]
					grid_data[y][x] = null
					var tile = grid_data[y][write_x]
					tile.position.x = write_x * 64
					tile.grid_position.x = write_x
				write_x -= 1

func is_grid_empty() -> bool:
	for y in range(level_data.grid_height):
		for x in range(level_data.grid_width):
			if grid_data[y][x]:
				return false
	return true

func rebuild_grid_from_data() -> void:
	# Clear existing tiles
	for y in range(grid_data.size()):
		for x in range(grid_data[y].size()):
			if grid_data[y][x] is Node2D:
				grid_data[y][x].queue_free()
	
	# Rebuild grid from saved data
	for y in range(grid_data.size()):
		for x in range(grid_data[y].size()):
			if grid_data[y][x] != null:
				var tile_data = grid_data[y][x]
				var tile = create_tile(x, y)
				tile.type = tile_data.type if tile_data.has("type") else 0
				grid_data[y][x] = tile